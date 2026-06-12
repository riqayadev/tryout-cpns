-- ============================================================
-- SkorinCPNS – Migrasi RLS admin dari hardcode email ke user_roles
-- Jalankan SETELAH create_roles.sql & set_admin.sql
--
-- admin_rls_extra.sql sebelumnya memberi akses penuh ke transaksi,
-- user_access, notifications, dan admin_config hanya untuk akun
-- dengan email riqayadev0921@gmail.com. Sekarang admin.html mengecek
-- role dari tabel user_roles, jadi policy di bawah ini menggantikan
-- policy lama agar siapa pun dengan role='admin' bisa mengelola
-- data tersebut.
-- ============================================================

-- transactions
DROP POLICY IF EXISTS "admin kelola semua transaksi" ON transactions;
CREATE POLICY "admin kelola semua transaksi" ON transactions FOR ALL
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));

-- user_access
DROP POLICY IF EXISTS "admin kelola semua akses" ON user_access;
CREATE POLICY "admin kelola semua akses" ON user_access FOR ALL
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));

-- notifications
DROP POLICY IF EXISTS "admin kelola semua notifikasi" ON notifications;
CREATE POLICY "admin kelola semua notifikasi" ON notifications FOR ALL
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));

-- admin_config (ubah PIN)
DROP POLICY IF EXISTS "admin update admin_config" ON admin_config;
CREATE POLICY "admin update admin_config" ON admin_config FOR UPDATE
  USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'))
  WITH CHECK (EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin'));

-- daftar semua user (section "Users" di admin panel)
CREATE OR REPLACE FUNCTION admin_list_users()
RETURNS TABLE(id uuid, email text, created_at timestamptz, full_name text)
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin') THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;
  RETURN QUERY
    SELECT u.id, u.email, u.created_at, u.raw_user_meta_data ->> 'full_name'
    FROM auth.users u;
END;
$$;

GRANT EXECUTE ON FUNCTION admin_list_users() TO authenticated;
