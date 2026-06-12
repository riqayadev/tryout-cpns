-- Jalankan ini di Supabase SQL Editor untuk set user jadi admin
-- Ganti UUID_USER_DISINI dengan UUID dari Supabase Authentication > Users

-- Kalau user belum ada di tabel user_roles:
INSERT INTO user_roles (user_id, role)
VALUES ('UUID_USER_DISINI', 'admin')
ON CONFLICT (user_id) DO UPDATE SET role = 'admin';

-- Untuk cabut akses admin:
-- UPDATE user_roles SET role = 'user' WHERE user_id = 'UUID_USER_DISINI';
