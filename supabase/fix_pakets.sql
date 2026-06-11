-- Hapus paket gratis-3/4/5 (sudah dialihkan jadi premium-1/2/3, fokus-twk, fokus-tiu)
-- dan rapikan nama paket premium menjadi penomoran #1-#5.
-- Jalankan via Supabase Dashboard → SQL Editor.

DELETE FROM pakets WHERE kode IN ('gratis-3', 'gratis-4', 'gratis-5');
UPDATE pakets SET nama = 'SKD Premium #1' WHERE kode = 'premium-1';
UPDATE pakets SET nama = 'SKD Premium #2' WHERE kode = 'premium-2';
UPDATE pakets SET nama = 'SKD Premium #3' WHERE kode = 'premium-3';
UPDATE pakets SET nama = 'SKD Premium #4' WHERE kode = 'fokus-twk';
UPDATE pakets SET nama = 'SKD Premium #5' WHERE kode = 'fokus-tiu';
