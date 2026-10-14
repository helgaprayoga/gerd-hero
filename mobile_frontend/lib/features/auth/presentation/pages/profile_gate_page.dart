import 'package:flutter/material.dart';

import '../../../../core/services/api_service.dart';
import '../../../home/presentation/models/profile_data.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../onboarding/presentation/pages/profile_page.dart';

/// Menentukan halaman setelah autentikasi berdasarkan profil yang tersimpan.
class ProfileGatePage extends StatefulWidget {
  const ProfileGatePage({super.key});

  @override
  State<ProfileGatePage> createState() => _ProfileGatePageState();
}

class _ProfileGatePageState extends State<ProfileGatePage> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolveDestination();
  }

  Future<void> _resolveDestination() async {
    try {
      final response = await ApiService.instance.get('/api/profile');
      final rawData = response['data'];
      if (rawData is! Map) {
        throw const FormatException('Data profil tidak valid.');
      }

      final profile = ProfileData.fromJson(Map<String, dynamic>.from(rawData));
      if (!mounted) return;

      final page = profile.hasBasicProfile
          ? HomePage(profile: profile)
          : const ProfilePage();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => page),
        (route) => false,
      );
    } on ApiException catch (error) {
      // A missing users row means onboarding still needs to be completed.
      if (error.statusCode == 404 && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
          (route) => false,
        );
        return;
      }
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Tidak dapat memuat profil dari server.');
      }
    }
  }

  void _retry() {
    setState(() => _error = null);
    _resolveDestination();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: _error == null
          ? const CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _retry,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
    ),
  );
}
