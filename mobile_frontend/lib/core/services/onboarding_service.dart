import 'api_service.dart';

class OnboardingStatus {
  const OnboardingStatus({
    required this.profileStatus,
    required this.gerdqStatus,
    required this.onboardingCompleted,
    required this.nextStep,
  });

  final String profileStatus;
  final String gerdqStatus;
  final bool onboardingCompleted;
  final String nextStep;

  factory OnboardingStatus.fromJson(Map<String, dynamic> json) {
    return OnboardingStatus(
      profileStatus: json['profile_status']?.toString() ?? 'pending',
      gerdqStatus: json['gerdq_status']?.toString() ?? 'pending',
      onboardingCompleted: json['onboarding_completed'] == true,
      nextStep: json['next_step']?.toString() ?? 'profile',
    );
  }
}

class OnboardingService {
  OnboardingService._();

  static final instance = OnboardingService._();

  Future<OnboardingStatus> getStatus() async {
    final response = await ApiService.instance.get('/api/onboarding/status');
    return OnboardingStatus.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<OnboardingStatus> setProfileStatus(String status) async {
    return _setStatus('/api/onboarding/profile', status);
  }

  Future<OnboardingStatus> setGerdqStatus(String status) async {
    return _setStatus('/api/onboarding/gerdq', status);
  }

  Future<OnboardingStatus> _setStatus(String path, String status) async {
    final response = await ApiService.instance.put(path, {'status': status});
    return OnboardingStatus.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }
}
