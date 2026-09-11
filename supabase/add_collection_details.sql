-- Enrichit le suivi personnel des bières (table `beer_status`, créée à la
-- main dans Supabase — voir lib/services/beer_collection_service.dart) :
-- statut "à goûter" (wishlist), date de dégustation et note libre.

alter table beer_status add column if not exists wishlist boolean not null default false;
alter table beer_status add column if not exists tried_at timestamptz;
alter table beer_status add column if not exists note text;
