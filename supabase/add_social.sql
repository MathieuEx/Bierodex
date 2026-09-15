-- Côté social : profils (pseudo + visibilité), amis, et bières proposées au
-- catalogue commun par la communauté.
-- À exécuter dans l'éditeur SQL de Supabase, après secure_auth.sql et
-- add_tasting_details.sql. Script idempotent.
--
-- Principe : les tables sociales ne s'ouvrent jamais directement aux autres
-- comptes. `beer_status`, `user_beers` et `profiles` restent lisibles par
-- leur seul propriétaire ; tout ce qu'un ami ou un visiteur peut voir passe
-- par des fonctions `security definer` qui vérifient les droits puis ne
-- renvoient qu'une liste fermée de colonnes (jamais les notes libres, les
-- fiches de dégustation, les photos, les codes-barres ni l'e-mail).
-- Côté app : lib/services/social_service.dart et
-- lib/services/submission_service.dart.

-- ===========================================================================
-- 1. Profils
-- ===========================================================================
create table if not exists profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  -- Pseudo unique, en minuscules : c'est lui qui apparaît dans le lien public.
  username text not null,
  display_name text,
  -- private : personne ; friends : amis acceptés ; public : tout le monde,
  -- y compris sans compte, via le lien de profil.
  visibility text not null default 'private',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists profiles_username_key on profiles (username);

alter table profiles drop constraint if exists profiles_bounds;
alter table profiles add constraint profiles_bounds check (
  username ~ '^[a-z0-9_]{3,20}$'
  and (display_name is null or char_length(display_name) between 1 and 40)
  and visibility in ('private', 'friends', 'public')
);

alter table profiles enable row level security;

drop policy if exists "Users manage their own profile" on profiles;
create policy "Users manage their own profile" on profiles
  for all
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- ===========================================================================
-- 2. Amitiés : une ligne par paire, en attente puis acceptée. Refuser,
--    annuler ou retirer un ami supprime la ligne.
-- ===========================================================================
create table if not exists friendships (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references auth.users(id) on delete cascade,
  addressee_id uuid not null references auth.users(id) on delete cascade,
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  responded_at timestamptz,
  constraint friendships_not_self check (requester_id <> addressee_id),
  constraint friendships_status check (status in ('pending', 'accepted'))
);

-- Une seule relation par paire, dans un sens comme dans l'autre.
create unique index if not exists friendships_pair_key on friendships (
  least(requester_id, addressee_id),
  greatest(requester_id, addressee_id)
);
create index if not exists friendships_addressee_idx on friendships (addressee_id);

alter table friendships enable row level security;

drop policy if exists "Users see their own friendships" on friendships;
create policy "Users see their own friendships" on friendships
  for select
  to authenticated
  using ((select auth.uid()) in (requester_id, addressee_id));

drop policy if exists "Users delete their own friendships" on friendships;
create policy "Users delete their own friendships" on friendships
  for delete
  to authenticated
  using ((select auth.uid()) in (requester_id, addressee_id));

-- Création et acceptation uniquement via les fonctions ci-dessous : une
-- insertion directe permettrait de se déclarer "ami accepté" de n'importe qui.
revoke insert, update on friendships from anon, authenticated;

-- ===========================================================================
-- 3. Fonctions d'accès
-- ===========================================================================
create or replace function are_friends(a uuid, b uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from friendships
    where status = 'accepted'
      and least(requester_id, addressee_id) = least(a, b)
      and greatest(requester_id, addressee_id) = greatest(a, b)
  );
$$;

-- `viewer` vaut null pour un visiteur sans compte.
create or replace function can_view_collection(owner uuid, viewer uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select owner = viewer
    or exists (
      select 1 from profiles p
      where p.user_id = owner
        and (
          p.visibility = 'public'
          or (p.visibility = 'friends' and viewer is not null and are_friends(owner, viewer))
        )
    );
$$;

-- Recherche exacte par pseudo (pas de recherche partielle : on ne veut pas
-- qu'on puisse lister les comptes). Réservée aux comptes connectés.
create or replace function find_profile(p_username text)
returns table (username text, display_name text, relation text)
language sql
stable
security definer
set search_path = public
as $$
  select
    p.username,
    p.display_name,
    case
      when p.user_id = auth.uid() then 'self'
      when f.status = 'accepted' then 'friend'
      when f.requester_id = auth.uid() then 'pending_sent'
      when f.addressee_id = auth.uid() then 'pending_received'
      else 'none'
    end
  from profiles p
  left join friendships f
    on least(f.requester_id, f.addressee_id) = least(p.user_id, auth.uid())
   and greatest(f.requester_id, f.addressee_id) = greatest(p.user_id, auth.uid())
  where auth.uid() is not null
    and p.username = lower(trim(p_username));
$$;

-- Envoie une demande d'ami. Si l'autre personne avait déjà envoyé une
-- demande, elle est acceptée directement.
create or replace function send_friend_request(p_username text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  me uuid := auth.uid();
  target uuid;
  existing friendships%rowtype;
begin
  if me is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;
  if not exists (select 1 from profiles where user_id = me) then
    raise exception 'profile_required' using errcode = 'P0001';
  end if;

  select user_id into target from profiles where username = lower(trim(p_username));
  if target is null then
    raise exception 'profile_not_found' using errcode = 'P0001';
  end if;
  if target = me then
    raise exception 'cannot_add_self' using errcode = 'P0001';
  end if;

  select * into existing from friendships
  where least(requester_id, addressee_id) = least(me, target)
    and greatest(requester_id, addressee_id) = greatest(me, target);

  if found then
    if existing.status = 'pending' and existing.addressee_id = me then
      update friendships set status = 'accepted', responded_at = now()
      where id = existing.id;
      return 'accepted';
    end if;
    return existing.status;
  end if;

  -- Garde-fou contre le spam de demandes.
  if (select count(*) from friendships where requester_id = me and status = 'pending') >= 50 then
    raise exception 'too_many_requests' using errcode = 'P0001';
  end if;

  insert into friendships (requester_id, addressee_id) values (me, target);
  return 'pending';
end;
$$;

-- Accepte une demande reçue (seul le destinataire peut le faire).
create or replace function accept_friend_request(p_request_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update friendships
  set status = 'accepted', responded_at = now()
  where id = p_request_id
    and addressee_id = auth.uid()
    and status = 'pending';
  if not found then
    raise exception 'request_not_found' using errcode = 'P0001';
  end if;
end;
$$;

-- Toutes mes relations (amis, demandes reçues et envoyées), avec le pseudo
-- de l'autre personne.
create or replace function list_friendships()
returns table (
  id uuid,
  username text,
  display_name text,
  status text,
  direction text,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    f.id,
    p.username,
    p.display_name,
    f.status,
    case when f.requester_id = auth.uid() then 'sent' else 'received' end,
    f.created_at
  from friendships f
  join profiles p
    on p.user_id = case when f.requester_id = auth.uid() then f.addressee_id else f.requester_id end
  where auth.uid() in (f.requester_id, f.addressee_id)
  order by f.status, p.username;
$$;

-- Profil partagé : en-tête + bières bues / à goûter avec note et date.
-- Renvoie null si le profil n'existe pas OU n'est pas visible par l'appelant
-- (les deux cas sont indiscernables, pour ne rien révéler aux visiteurs).
-- Les bières ajoutées à la main sont jointes (nom, brasserie, pays, style,
-- degré) puisqu'elles n'existent pas dans le catalogue du visiteur.
create or replace function get_shared_profile(p_username text)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  owner profiles%rowtype;
begin
  select * into owner from profiles where username = lower(trim(p_username));
  if not found or not can_view_collection(owner.user_id, auth.uid()) then
    return null;
  end if;

  return jsonb_build_object(
    'username', owner.username,
    'display_name', owner.display_name,
    'visibility', owner.visibility,
    'is_self', owner.user_id = auth.uid(),
    'entries', coalesce((
      select jsonb_agg(jsonb_build_object(
        'beer_id', s.beer_id,
        'tried', s.tried,
        'wishlist', s.wishlist,
        'rating', s.rating,
        'tried_at', s.tried_at
      ) order by s.tried_at desc nulls last)
      from beer_status s
      where s.user_id = owner.user_id and (s.tried or s.wishlist)
    ), '[]'::jsonb),
    'custom_beers', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', b.id,
        'name', b.name,
        'brewery', b.brewery,
        'country', b.country,
        'style_id', b.style_id,
        'abv', b.abv,
        'description', b.description,
        'image_url', b.image_url,
        'image_credit', b.image_credit
      ))
      from user_beers b
      where b.user_id = owner.user_id
        and exists (
          select 1 from beer_status s
          where s.user_id = owner.user_id and s.beer_id = b.id and (s.tried or s.wishlist)
        )
    ), '[]'::jsonb)
  );
end;
$$;

-- ===========================================================================
-- 4. Bières proposées au catalogue commun
-- ===========================================================================
-- Liste des modérateurs, gérée uniquement depuis le tableau de bord :
--   insert into moderators (user_id) values ('<uuid du compte>');
create table if not exists moderators (
  user_id uuid primary key references auth.users(id) on delete cascade,
  added_at timestamptz not null default now()
);
alter table moderators enable row level security;
-- Aucune policy : illisible et non modifiable via l'API.
revoke all on moderators from anon, authenticated;

create or replace function is_moderator()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from moderators where user_id = auth.uid());
$$;

create table if not exists beer_submissions (
  id uuid primary key default gen_random_uuid(),
  -- Bière du carnet personnel d'origine (`user_beers.id`). Pas de clé
  -- étrangère : la proposition doit survivre à la migration vers le
  -- catalogue, qui supprime la bière personnelle.
  user_beer_id text not null,
  submitted_by uuid not null references auth.users(id) on delete cascade,
  name text not null,
  brewery text not null,
  country text not null,
  style_id text not null references beer_styles(id),
  abv double precision not null,
  description text not null default '',
  barcode text,
  image_url text,
  image_credit text,
  status text not null default 'pending',
  review_note text,
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewed_at timestamptz,
  catalog_beer_id text references beers(id) on delete set null,
  created_at timestamptz not null default now()
);

alter table beer_submissions drop constraint if exists beer_submissions_bounds;
alter table beer_submissions add constraint beer_submissions_bounds check (
  status in ('pending', 'approved', 'rejected')
  and char_length(name) between 1 and 200
  and char_length(brewery) between 1 and 200
  and char_length(country) between 1 and 100
  and char_length(description) <= 2000
  and abv >= 0 and abv <= 100
  and (barcode is null or barcode ~ '^[0-9]{6,14}$')
  and (image_url is null or (image_url ~ '^https://' and char_length(image_url) <= 2000))
  and (image_credit is null or char_length(image_credit) <= 300)
  and (review_note is null or char_length(review_note) <= 500)
);

-- Une seule proposition en cours (ou acceptée) par bière personnelle ; une
-- proposition refusée peut être renvoyée.
create unique index if not exists beer_submissions_active_key
  on beer_submissions (submitted_by, user_beer_id)
  where status <> 'rejected';
create index if not exists beer_submissions_pending_idx
  on beer_submissions (created_at)
  where status = 'pending';

alter table beer_submissions enable row level security;

drop policy if exists "Submitters and moderators read submissions" on beer_submissions;
create policy "Submitters and moderators read submissions" on beer_submissions
  for select
  to authenticated
  using ((select auth.uid()) = submitted_by or (select is_moderator()));

drop policy if exists "Submitters withdraw pending submissions" on beer_submissions;
create policy "Submitters withdraw pending submissions" on beer_submissions
  for delete
  to authenticated
  using ((select auth.uid()) = submitted_by and status = 'pending');

revoke insert, update on beer_submissions from anon, authenticated;

-- Propose une bière du carnet personnel : les champs sont recopiés côté
-- serveur depuis `user_beers`, jamais pris dans la requête.
create or replace function submit_user_beer(p_user_beer_id text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  me uuid := auth.uid();
  source user_beers%rowtype;
  new_id uuid;
begin
  if me is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  select * into source from user_beers where id = p_user_beer_id and user_id = me;
  if not found then
    raise exception 'beer_not_found' using errcode = 'P0001';
  end if;

  if exists (
    select 1 from beer_submissions
    where submitted_by = me and user_beer_id = p_user_beer_id and status <> 'rejected'
  ) then
    raise exception 'already_submitted' using errcode = 'P0001';
  end if;

  if source.barcode is not null and exists (select 1 from beers where barcode = source.barcode) then
    raise exception 'already_in_catalog' using errcode = 'P0001';
  end if;

  if (select count(*) from beer_submissions where submitted_by = me and status = 'pending') >= 20 then
    raise exception 'too_many_submissions' using errcode = 'P0001';
  end if;

  insert into beer_submissions (
    user_beer_id, submitted_by, name, brewery, country, style_id, abv,
    description, barcode, image_url, image_credit
  ) values (
    source.id, me, source.name, source.brewery, source.country, source.style_id,
    source.abv, source.description, source.barcode, source.image_url, source.image_credit
  )
  returning id into new_id;
  return new_id;
end;
$$;

-- Validation par un modérateur, qui peut corriger les champs au passage
-- (null = garder la valeur proposée). Accepter crée la bière dans le
-- catalogue commun ; l'app de l'auteur rattache ensuite sa collection à la
-- nouvelle fiche (voir SubmissionService.adoptApprovedBeers).
create or replace function review_submission(
  p_submission_id uuid,
  p_approve boolean,
  p_note text default null,
  p_name text default null,
  p_brewery text default null,
  p_country text default null,
  p_style_id text default null,
  p_abv double precision default null,
  p_description text default null
)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  submission beer_submissions%rowtype;
  beer_id text;
begin
  if not is_moderator() then
    raise exception 'not_moderator' using errcode = '42501';
  end if;

  select * into submission from beer_submissions
  where id = p_submission_id and status = 'pending'
  for update;
  if not found then
    raise exception 'submission_not_found' using errcode = 'P0001';
  end if;

  if not p_approve then
    update beer_submissions
    set status = 'rejected', review_note = nullif(trim(p_note), ''),
        reviewed_by = auth.uid(), reviewed_at = now()
    where id = p_submission_id;
    return null;
  end if;

  update beer_submissions set
    name = coalesce(nullif(trim(p_name), ''), name),
    brewery = coalesce(nullif(trim(p_brewery), ''), brewery),
    country = coalesce(nullif(trim(p_country), ''), country),
    style_id = coalesce(p_style_id, style_id),
    abv = coalesce(p_abv, abv),
    description = coalesce(p_description, description)
  where id = p_submission_id
  returning * into submission;

  beer_id := 'community-' || replace(gen_random_uuid()::text, '-', '');
  insert into beers (
    id, name, brewery, country, style_id, abv, description, barcode, image_url, image_credit
  ) values (
    beer_id, submission.name, submission.brewery, submission.country, submission.style_id,
    submission.abv, submission.description, submission.barcode, submission.image_url,
    submission.image_credit
  );

  update beer_submissions
  set status = 'approved', review_note = nullif(trim(p_note), ''),
      reviewed_by = auth.uid(), reviewed_at = now(), catalog_beer_id = beer_id
  where id = p_submission_id;
  return beer_id;
end;
$$;

-- ===========================================================================
-- 5. Droits d'exécution : par défaut, Postgres autorise toute fonction à
--    `public` (donc à `anon`). On restreint explicitement.
-- ===========================================================================
revoke execute on function are_friends(uuid, uuid) from public, anon, authenticated;
revoke execute on function can_view_collection(uuid, uuid) from public, anon, authenticated;
revoke execute on function find_profile(text) from public, anon;
revoke execute on function send_friend_request(text) from public, anon;
revoke execute on function accept_friend_request(uuid) from public, anon;
revoke execute on function list_friendships() from public, anon;
revoke execute on function get_shared_profile(text) from public;
revoke execute on function is_moderator() from public, anon;
revoke execute on function submit_user_beer(text) from public, anon;
revoke execute on function review_submission(uuid, boolean, text, text, text, text, text, double precision, text) from public, anon;

grant execute on function find_profile(text) to authenticated;
grant execute on function send_friend_request(text) to authenticated;
grant execute on function accept_friend_request(uuid) to authenticated;
grant execute on function list_friendships() to authenticated;
-- Seule fonction ouverte aux visiteurs sans compte (lien de profil public).
grant execute on function get_shared_profile(text) to anon, authenticated;
grant execute on function is_moderator() to authenticated;
grant execute on function submit_user_beer(text) to authenticated;
grant execute on function review_submission(uuid, boolean, text, text, text, text, text, double precision, text) to authenticated;
