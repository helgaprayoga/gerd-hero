import 'package:supabase_flutter/supabase_flutter.dart';

/// Single entry point for Supabase authentication operations.
///
/// UI pages should use this service instead of calling Supabase Auth directly.
class AuthService {
  AuthService._();

  static final instance = AuthService._();

  static const oauthRedirectUrl = 'io.supabase.gerdhero://login-callback';
  static const passwordResetRedirectUrl =
      'io.supabase.gerdhero://password-reset';

  bool _isPasswordRecovery = false;

  GoTrueClient get _auth => Supabase.instance.client.auth;

  Future<AuthResponse> register({
    required String email,
    required String password,
    String? name,
    String? nickname,
  }) {
    return _auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      data: {
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        if (nickname != null && nickname.trim().isNotEmpty)
          'nickname': nickname.trim(),
      },
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<bool> signInWithGoogle() {
    return _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: oauthRedirectUrl,
    );
  }

  Future<void> resendVerification(String email) {
    return _auth.resend(
      type: OtpType.signup,
      email: email.trim().toLowerCase(),
    );
  }

  Future<void> requestPasswordReset(String email) {
    return _auth.resetPasswordForEmail(
      email.trim().toLowerCase(),
      redirectTo: passwordResetRedirectUrl,
    );
  }

  Future<UserResponse> updatePassword(String password) {
    return _auth.updateUser(UserAttributes(password: password));
  }

  Future<Session?> refreshSession() async {
    final response = await _auth.refreshSession();
    return response.session;
  }

  Future<void> signOut() {
    return _auth.signOut(scope: SignOutScope.local);
  }

  Session? get currentSession => _auth.currentSession;

  bool get isPasswordRecovery => _isPasswordRecovery;

  void markPasswordRecovery() => _isPasswordRecovery = true;

  void clearPasswordRecovery() => _isPasswordRecovery = false;
}
