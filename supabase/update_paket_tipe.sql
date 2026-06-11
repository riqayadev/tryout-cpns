-- Ubah tipe paket gratis-3, gratis-4, gratis-5 menjadi 'premium'.
-- Jalankan via Supabase Dashboard → SQL Editor.

UPDATE pakets
SET tipe = 'premium'
WHERE kode IN ('gratis-3', 'gratis-4', 'gratis-5');
