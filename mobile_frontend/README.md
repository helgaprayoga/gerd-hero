# mobile_frontend

## Supabase Auth deep links

Tambahkan URL berikut ke **Supabase Dashboard → Authentication → URL Configuration → Redirect URLs**:

```text
io.supabase.gerdhero://login-callback
io.supabase.gerdhero://password-reset
```

URL `password-reset` diperlukan agar tautan dari email dapat membuka aplikasi dan
mengaktifkan halaman pembuatan kata sandi baru.

A new Flutter project.
