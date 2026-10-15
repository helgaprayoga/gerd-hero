import 'package:supabase_flutter/supabase_flutter.dart';

String authErrorMessage(
  Object error, {
  required bool isLogin,
  bool isPasswordReset = false,
}) {
  if (error is AuthException) {
    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();

    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return 'Email atau password salah.';
    }
    if (code == 'email_not_confirmed' ||
        message.contains('email not confirmed')) {
      return 'Silakan verifikasi email terlebih dahulu.';
    }
    if (code == 'user_already_exists' ||
        code == 'email_exists' ||
        message.contains('already registered')) {
      return 'Email tidak dapat digunakan. Silakan gunakan email lain atau login.';
    }
    if (code == 'weak_password' || message.contains('weak password')) {
      return 'Password belum memenuhi persyaratan.';
    }
    if (code == 'over_request_rate_limit' ||
        code == 'over_email_send_rate_limit' ||
        message.contains('rate limit')) {
      return 'Terlalu banyak percobaan. Coba lagi nanti.';
    }
    if (isPasswordReset &&
        (code == 'otp_expired' ||
            code == 'flow_state_expired' ||
            message.contains('expired') ||
            (message.contains('invalid') && message.contains('link')) ||
            (message.contains('invalid') && message.contains('token')))) {
      return 'Tautan pengaturan ulang sudah tidak berlaku. Minta tautan baru.';
    }
    if (code == 'email_address_invalid' || message.contains('invalid email')) {
      return 'Format email tidak valid.';
    }
    if (code == 'user_cancelled' ||
        code == 'oauth_canceled' ||
        message.contains('cancel')) {
      return 'Login Google dibatalkan.';
    }
  }

  if (error is AuthRetryableFetchException ||
      error.toString().toLowerCase().contains('socketexception')) {
    return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
  }

  return isLogin
      ? 'Gagal masuk. Silakan coba lagi.'
      : isPasswordReset
      ? 'Permintaan pengaturan ulang gagal. Silakan coba lagi.'
      : 'Registrasi gagal. Silakan coba lagi.';
}
