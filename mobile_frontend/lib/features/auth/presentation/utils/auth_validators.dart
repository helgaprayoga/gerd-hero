bool isValidEmail(String value) {
  final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  return emailPattern.hasMatch(value);
}

String? emailError(String value) {
  if (value.isEmpty || isValidEmail(value)) return null;
  return 'Format email tidak valid';
}

String? passwordError(String value) {
  if (value.isEmpty || value.length >= 8) return null;
  return 'Minimal 8 karakter';
}

String? confirmPasswordError(String password, String confirmation) {
  if (confirmation.isEmpty || password == confirmation) return null;
  return 'Kata sandi tidak cocok';
}
