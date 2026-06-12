-- ============================================================
-- SkorinCPNS – RLS tambahan untuk Admin Panel (admin.html)
-- Jalankan SETELAH create_premium_system.sql di Supabase Dashboard → SQL Editor
--
-- create_premium_system.sql hanya memberi setiap user akses ke
-- baris miliknya sendiri (auth.uid() = user_id). Admin Panel perlu
-- membaca & mengubah data SEMUA user (konfirmasi transaksi, buka
-- akses, kirim notifikasi, ubah PIN) — policy di bawah ini menambah
-- akses penuh khusus untuk akun admin (dicek dari email di JWT).
-- ============================================================

-- transactions: admin bisa baca & ubah semua transaksi
CREATE POLICY "admin kelola semua transaksi" ON transactions FOR ALL
  USING (auth.jwt() ->> 'email' = 'riqayadev0921@gmail.com')
  WITH CHECK (auth.jwt() ->> 'email' = 'riqayadev0921@gmail.com');

-- user_access: admin bisa baca, beri, perpanjang, & cabut akses semua user
CREATE POLICY "admin kelola semua akses" ON user_access FOR ALL
  USING (auth.jwt() ->> 'email' = 'riqayadev0921@gmail.com')
  WITH CHECK (auth.jwt() ->> 'email' = 'riqayadev0921@gmail.com');

-- notifications: admin bisa mengirim notifikasi ke semua user
CREATE POLICY "admin kelola semua notifikasi" ON notifications FOR ALL
  USING (auth.jwt() ->> 'email' = 'riqayadev0921@gmail.com')
  WITH CHECK (auth.jwt() ->> 'email' = 'riqayadev0921@gmail.com');

-- admin_config: admin bisa mengubah PIN
CREATE POLICY "admin update admin_config" ON admin_config FOR UPDATE
  USING (auth.jwt() ->> 'email' = 'riqayadev0921@gmail.com')
  WITH CHECK (auth.jwt() ->> 'email' = 'riqayadev0921@gmail.com');

-- ============================================================
-- Opsional: fungsi untuk menampilkan daftar SEMUA user terdaftar
-- (termasuk yang belum pernah tryout) di section "Users".
-- Tanpa fungsi ini, admin.html tetap berjalan — daftar user dibangun
-- dari hasil_tryout + transactions + user_access.
-- ============================================================
CREATE OR REPLACE FUNCTION admin_list_users()
RETURNS TABLE(id uuid, email text, created_at timestamptz, full_name text)
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  IF auth.jwt() ->> 'email' <> 'riqayadev0921@gmail.com' THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;
  RETURN QUERY
    SELECT u.id, u.email, u.created_at, u.raw_user_meta_data ->> 'full_name'
    FROM auth.users u;
END;
$$;

GRANT EXECUTE ON FUNCTION admin_list_users() TO authenticated;
