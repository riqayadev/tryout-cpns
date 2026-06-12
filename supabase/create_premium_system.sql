-- ============================================================
-- SkorinCPNS – Sistem Premium (Transaksi, Akses, Notifikasi, Admin)
-- Jalankan di Supabase Dashboard → SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS transactions (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  user_email text not null,
  user_name text,
  paket_id text,
  tipe text not null check (tipe in ('satuan', 'membership')),
  harga integer not null,
  status text not null default 'pending' check (status in ('pending', 'confirmed', 'cancelled')),
  catatan text,
  created_at timestamptz default now(),
  confirmed_at timestamptz,
  confirmed_by text
);

CREATE TABLE IF NOT EXISTS user_access (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  paket_id text not null,
  tipe text not null check (tipe in ('satuan', 'membership')),
  transaction_id bigint references transactions(id),
  created_at timestamptz default now(),
  expires_at timestamptz,
  unique(user_id, paket_id)
);

CREATE TABLE IF NOT EXISTS notifications (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  judul text not null,
  pesan text not null,
  tipe text default 'info' check (tipe in ('info', 'success', 'warning')),
  dibaca boolean default false,
  created_at timestamptz default now()
);

CREATE TABLE IF NOT EXISTS admin_config (
  id bigint generated always as identity primary key,
  key text unique not null,
  value text not null,
  updated_at timestamptz default now()
);

-- Insert PIN default (ganti setelah deploy!)
INSERT INTO admin_config (key, value) VALUES ('admin_pin', '082604');

-- RLS transactions
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "user lihat transaksi sendiri" ON transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "user insert transaksi sendiri" ON transactions FOR INSERT WITH CHECK (auth.uid() = user_id);

-- RLS user_access
ALTER TABLE user_access ENABLE ROW LEVEL SECURITY;
CREATE POLICY "user lihat akses sendiri" ON user_access FOR SELECT USING (auth.uid() = user_id);

-- RLS notifications
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "user lihat notifikasi sendiri" ON notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "user update notifikasi sendiri" ON notifications FOR UPDATE USING (auth.uid() = user_id);

-- RLS admin_config (hanya bisa dibaca, tidak bisa diubah dari client)
ALTER TABLE admin_config ENABLE ROW LEVEL SECURITY;
CREATE POLICY "semua bisa baca admin_config" ON admin_config FOR SELECT USING (true);
