-- Drop policy lama yang circular
DROP POLICY IF EXISTS "admin bisa lihat semua role" ON user_roles;
DROP POLICY IF EXISTS "user lihat role sendiri" ON user_roles;

-- Buat policy baru yang tidak circular
CREATE POLICY "user lihat role sendiri" ON user_roles
FOR SELECT USING (auth.uid() = user_id);
