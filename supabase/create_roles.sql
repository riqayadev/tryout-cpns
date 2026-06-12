CREATE TABLE IF NOT EXISTS user_roles (
  user_id uuid references auth.users(id) on delete cascade primary key,
  role text not null default 'user' check (role in ('user', 'admin')),
  created_at timestamptz default now()
);

ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "user lihat role sendiri" ON user_roles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "admin bisa lihat semua role" ON user_roles FOR SELECT USING (
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
);
