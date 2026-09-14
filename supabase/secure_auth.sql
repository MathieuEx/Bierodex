-- Durcissement côté serveur, à exécuter dans l'éditeur SQL de Supabase.
-- Script idempotent : peut être rejoué sans risque.
--
-- La clé "anon" est embarquée dans l'app : n'importe qui peut l'extraire et
-- appeler l'API directement, sans passer par l'interface. Ce sont donc ces
-- règles (RLS + contraintes), et non l'app, qui protègent réellement les
-- données. Côté injections SQL : l'app ne construit aucune requête à la
-- main (PostgREST paramètre tout), et aucune fonction SQL ci-dessous
-- n'exécute de SQL dynamique.

-- ---------------------------------------------------------------------------
-- 1. beer_status (créée à la main dans le tableau de bord) : chacun ne lit
--    et n'écrit que ses propres lignes.
-- ---------------------------------------------------------------------------
alter table beer_status enable row level security;

drop policy if exists "Users manage their own statuses" on beer_status;
create policy "Users manage their own statuses" on beer_status
  for all
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- `not valid` : ne bloque pas la migration si d'anciennes lignes dérogent,
-- mais s'applique à toute nouvelle écriture.
alter table beer_status drop constraint if exists beer_status_rating_range;
alter table beer_status add constraint beer_status_rating_range
  check (rating is null or rating between 1 and 5) not valid;

alter table beer_status drop constraint if exists beer_status_note_length;
alter table beer_status add constraint beer_status_note_length
  check (note is null or char_length(note) <= 2000) not valid;

alter table beer_status drop constraint if exists beer_status_beer_id_length;
alter table beer_status add constraint beer_status_beer_id_length
  check (char_length(beer_id) <= 200) not valid;

-- ---------------------------------------------------------------------------
-- 2. user_beers : policy limitée aux utilisateurs connectés + bornes sur
--    tout ce qui est saisi librement.
-- ---------------------------------------------------------------------------
drop policy if exists "Users manage their own beers" on user_beers;
create policy "Users manage their own beers" on user_beers
  for all
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

alter table user_beers drop constraint if exists user_beers_input_bounds;
alter table user_beers add constraint user_beers_input_bounds check (
  char_length(id) <= 200
  and char_length(name) between 1 and 200
  and char_length(brewery) between 1 and 200
  and char_length(country) between 1 and 100
  and char_length(description) <= 2000
  and abv >= 0 and abv <= 100
  and (barcode is null or barcode ~ '^[0-9]{6,14}$')
  and (image_credit is null or char_length(image_credit) <= 300)
  -- Uniquement des images en HTTPS (pas de http:, data:, javascript:...).
  and (image_url is null or (image_url ~ '^https://' and char_length(image_url) <= 2000))
) not valid;

-- ---------------------------------------------------------------------------
-- 3. Catalogue partagé : lecture seule pour tout le monde. Les policies
--    n'autorisent déjà que `select` ; on retire en plus les droits
--    d'écriture, au cas où une policy trop large serait ajoutée un jour.
-- ---------------------------------------------------------------------------
revoke insert, update, delete, truncate on beer_styles, beers, brewery_locations
  from anon, authenticated;

-- ---------------------------------------------------------------------------
-- Réglages à faire dans le tableau de bord (non scriptables en SQL) :
--   Authentication > Providers > Email
--     - "Email OTP Expiration" : 600 s (10 min) au lieu de 3600
--     - "Email OTP Length" : 6 (l'app attend 6 chiffres)
--   Authentication > Rate Limits : garder les limites par défaut ou plus
--     strictes (envois d'e-mails / vérifications OTP par heure et par IP)
--   Authentication > Attack Protection : activer le captcha (Turnstile ou
--     hCaptcha) si des inscriptions en masse apparaissent
--   Authentication > Sessions : "Detect and revoke potentially compromised
--     refresh tokens" activé (rotation des refresh tokens)
--   Authentication > URL Configuration : Site URL = l'URL de prod du web,
--     aucune redirection générique (`*`)
-- ---------------------------------------------------------------------------
