-- Fiche de dégustation détaillée et photo de dégustation.
-- À exécuter dans l'éditeur SQL de Supabase. Script idempotent.
-- Côté app : lib/models/beer_user_status.dart (toRow / fromRow) et
-- lib/services/tasting_photo_service.dart.

-- ---------------------------------------------------------------------------
-- 1. beer_status : critères de 1 à 5, arômes cochés, chemin de la photo.
-- ---------------------------------------------------------------------------
alter table beer_status add column if not exists color smallint;
alter table beer_status add column if not exists bitterness smallint;
alter table beer_status add column if not exists sweetness smallint;
alter table beer_status add column if not exists body smallint;
alter table beer_status add column if not exists aromas text[] not null default '{}';
alter table beer_status add column if not exists photo_path text;

alter table beer_status drop constraint if exists beer_status_tasting_bounds;
alter table beer_status add constraint beer_status_tasting_bounds check (
  (color is null or color between 1 and 5)
  and (bitterness is null or bitterness between 1 and 5)
  and (sweetness is null or sweetness between 1 and 5)
  and (body is null or body between 1 and 5)
  and cardinality(aromas) <= 30
  and array_to_string(aromas, '') ~ '^[a-z_]*$'
  -- La photo doit vivre dans le dossier du propriétaire de la ligne : une
  -- ligne ne peut pas pointer vers la photo de quelqu'un d'autre.
  and (
    photo_path is null
    or (
      photo_path like user_id::text || '/%'
      and char_length(photo_path) <= 300
      and photo_path !~ '\.\.'
    )
  )
) not valid;

-- ---------------------------------------------------------------------------
-- 2. Bucket privé `tasting-photos` : JPEG uniquement, 5 Mo maximum.
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('tasting-photos', 'tasting-photos', false, 5242880, array['image/jpeg'])
on conflict (id) do update set
  public = false,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- Chaque compte ne voit, n'ajoute et ne supprime que les fichiers de son
-- propre dossier `<user_id>/...`. Aucune policy pour `anon`.
drop policy if exists "Tasting photos: read own" on storage.objects;
create policy "Tasting photos: read own" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'tasting-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "Tasting photos: upload own" on storage.objects;
create policy "Tasting photos: upload own" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'tasting-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "Tasting photos: delete own" on storage.objects;
create policy "Tasting photos: delete own" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'tasting-photos'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
