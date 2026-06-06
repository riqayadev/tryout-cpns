-- ============================================================
-- SkorinCPNS – Database Schema
-- Jalankan di Supabase Dashboard → SQL Editor
-- ============================================================

-- 1. Tabel Paket Tryout
CREATE TABLE IF NOT EXISTS pakets (
  id          SERIAL PRIMARY KEY,
  kode        VARCHAR(50)  UNIQUE NOT NULL,
  nama        VARCHAR(200) NOT NULL,
  tipe        VARCHAR(20)  NOT NULL CHECK (tipe IN ('gratis','premium')),
  level       VARCHAR(50),
  deskripsi   TEXT,
  icon        VARCHAR(10)  DEFAULT '📝',
  total_soal  INTEGER      DEFAULT 110,
  aktif       BOOLEAN      DEFAULT true,
  created_at  TIMESTAMPTZ  DEFAULT NOW()
);

-- 2. Tabel Soal
CREATE TABLE IF NOT EXISTS soal (
  id          SERIAL PRIMARY KEY,
  paket_id    INTEGER      NOT NULL REFERENCES pakets(id) ON DELETE CASCADE,
  nomor       INTEGER      NOT NULL,
  tipe        VARCHAR(5)   NOT NULL CHECK (tipe IN ('TWK','TIU','TKP')),
  teks        TEXT         NOT NULL,
  opsi        TEXT[]       NOT NULL,   -- 5 pilihan jawaban
  benar       SMALLINT,               -- index 0-4; NULL untuk TKP
  nilai       INTEGER[],              -- TKP: skor per opsi [1..5]
  pembahasan  TEXT,
  topik       VARCHAR(100),
  created_at  TIMESTAMPTZ  DEFAULT NOW(),
  UNIQUE(paket_id, nomor)
);

CREATE INDEX IF NOT EXISTS idx_soal_paket   ON soal(paket_id);
CREATE INDEX IF NOT EXISTS idx_soal_tipe    ON soal(tipe);

-- 3. RLS – buka akses publik untuk seeding & baca soal oleh user terautentikasi
ALTER TABLE pakets ENABLE ROW LEVEL SECURITY;
ALTER TABLE soal   ENABLE ROW LEVEL SECURITY;

-- pakets: siapa saja (termasuk anon) bisa baca; hanya service_role yg bisa tulis
DROP POLICY IF EXISTS "pakets_public_read"  ON pakets;
CREATE POLICY "pakets_public_read" ON pakets
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "pakets_service_write" ON pakets;
CREATE POLICY "pakets_service_write" ON pakets
  FOR ALL TO service_role USING (true) WITH CHECK (true);

-- soal: user login bisa baca; hanya service_role yg bisa tulis
DROP POLICY IF EXISTS "soal_auth_read"   ON soal;
CREATE POLICY "soal_auth_read" ON soal
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "soal_service_write" ON soal;
CREATE POLICY "soal_service_write" ON soal
  FOR ALL TO service_role USING (true) WITH CHECK (true);

-- 4. Sementara izinkan anon INSERT untuk proses seeding (hapus setelah seed selesai)
DROP POLICY IF EXISTS "soal_anon_insert_seed"   ON soal;
CREATE POLICY "soal_anon_insert_seed" ON soal
  FOR INSERT TO anon WITH CHECK (true);

DROP POLICY IF EXISTS "pakets_anon_insert_seed" ON pakets;
CREATE POLICY "pakets_anon_insert_seed" ON pakets
  FOR INSERT TO anon WITH CHECK (true);

-- 5. Tabel Hasil Tryout
-- Jalankan di Supabase Dashboard → SQL Editor
CREATE TABLE IF NOT EXISTS hasil_tryout (
  id           SERIAL PRIMARY KEY,
  user_id      UUID         NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  paket_id     INTEGER      REFERENCES pakets(id) ON DELETE SET NULL,
  paket_nama   VARCHAR(200),
  skor_twk     INTEGER      NOT NULL DEFAULT 0,
  skor_tiu     INTEGER      NOT NULL DEFAULT 0,
  skor_tkp     INTEGER      NOT NULL DEFAULT 0,
  skor_total   INTEGER      NOT NULL DEFAULT 0,
  status_lulus BOOLEAN      NOT NULL DEFAULT false,
  tanggal      TIMESTAMPTZ  DEFAULT NOW(),
  created_at   TIMESTAMPTZ  DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_hasil_user  ON hasil_tryout(user_id);
CREATE INDEX IF NOT EXISTS idx_hasil_paket ON hasil_tryout(paket_id);

ALTER TABLE hasil_tryout ENABLE ROW LEVEL SECURITY;

-- User bisa menyimpan hasil tryoutnya sendiri
DROP POLICY IF EXISTS "hasil_user_insert" ON hasil_tryout;
CREATE POLICY "hasil_user_insert" ON hasil_tryout
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

-- User hanya bisa membaca hasil miliknya sendiri
DROP POLICY IF EXISTS "hasil_user_read" ON hasil_tryout;
CREATE POLICY "hasil_user_read" ON hasil_tryout
  FOR SELECT TO authenticated USING (user_id = auth.uid());
