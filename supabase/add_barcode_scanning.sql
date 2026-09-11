-- Scan de code-barres (lib/screens/barcode_scanner_screen.dart) : retrouver
-- une bière du catalogue partagé par son EAN/UPC, ou l'ajouter au carnet
-- personnel si elle est absente.

-- Colonne facultative sur le catalogue partagé, à renseigner au fil de
-- l'eau (comme les photos/logos) pour que le scan retrouve directement les
-- bières déjà cataloguées.
alter table beers add column if not exists barcode text;
create index if not exists beers_barcode_idx on beers (barcode);

-- Bières ajoutées à la main par un utilisateur quand le scan ne trouve
-- rien dans `beers`. Contrairement au catalogue partagé, cette table est
-- écrite par les utilisateurs eux-mêmes : chacun ne voit et ne modifie que
-- ses propres ajouts (voir lib/services/user_beer_service.dart).
create table if not exists user_beers (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  brewery text not null,
  country text not null,
  style_id text not null references beer_styles(id),
  abv double precision not null,
  description text not null default '',
  barcode text,
  image_url text,
  image_credit text,
  created_at timestamptz not null default now()
);

alter table user_beers enable row level security;

create policy "Users manage their own beers" on user_beers
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create index if not exists user_beers_barcode_idx on user_beers (barcode);
