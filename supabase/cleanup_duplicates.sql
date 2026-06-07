-- Hapus baris duplikat di hasil_tryout (sisakan baris paling lama / id terkecil
-- per kombinasi user_id + paket_id + attempt_number).
-- Penyebab duplikat: hasil.html dulu mencatat ulang ke Supabase setiap kali dibuka
-- (sudah diperbaiki — sekarang hanya dicatat sekali saat submit di tryout.html).
--
-- Jalankan via Supabase Dashboard → SQL Editor.

DELETE FROM hasil_tryout WHERE id NOT IN (
  SELECT MIN(id) FROM hasil_tryout
  GROUP BY user_id, paket_id, attempt_number
);
