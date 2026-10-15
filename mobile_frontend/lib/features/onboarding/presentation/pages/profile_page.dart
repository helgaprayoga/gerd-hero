import 'package:flutter/material.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/auth_privacy_note.dart';
import '../../../home/presentation/models/profile_data.dart';
import '../widgets/bmi_card.dart';
import '../widgets/profile_form_card.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_intro_card.dart';
import 'gerdq_intro_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  bool _isLoading = false;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_refresh);
    _heightController.addListener(_refresh);
    _weightController.addListener(_refresh);
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _loadProfile() async {
    try {
      final response = await ApiService.instance.get('/api/profile');
      final rawData = response['data'];
      if (rawData is Map && mounted) {
        final profile = ProfileData.fromJson(
          Map<String, dynamic>.from(rawData),
        );
        // Jangan menimpa input yang sedang diketik pengguna.
        if (_nameController.text.isEmpty &&
            _heightController.text.isEmpty &&
            _weightController.text.isEmpty &&
            _birthDate == null) {
          _nameController.text = profile.nickname ?? '';
          _heightController.text = _formatNumber(profile.height);
          _weightController.text = _formatNumber(profile.weight);
          _birthDate = profile.birthDate;
          _gender = switch (profile.gender) {
            'male' => 'Laki-laki',
            'female' => 'Perempuan',
            _ => null,
          };
        }
      }
    } catch (_) {
      // Form tetap dapat diisi ketika profil belum tersedia atau server gagal.
    } finally {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  String _formatNumber(double? value) => value == null
      ? ''
      : value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  double? _parseMeasurement(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  void _showValidationError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Validasi form, simpan profil ke backend, lalu lanjut ke GERD-Q.
  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama panggilan wajib diisi.')),
      );
      return;
    }
    if (_birthDate == null) {
      _showValidationError('Tanggal lahir wajib diisi.');
      return;
    }
    if (_gender == null) {
      _showValidationError('Jenis kelamin wajib dipilih.');
      return;
    }

    final height = _parseMeasurement(_heightController.text);
    if (height == null || height <= 0) {
      _showValidationError('Tinggi badan wajib diisi dengan angka yang valid.');
      return;
    }

    final weight = _parseMeasurement(_weightController.text);
    if (weight == null || weight <= 0) {
      _showValidationError('Berat badan wajib diisi dengan angka yang valid.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.instance.put('/api/profile', {
        'nickname': _nameController.text.trim(),
        'birth_date': _birthDate!.toIso8601String().substring(0, 10),
        'gender': _gender == 'Laki-laki' ? 'male' : 'female',
        'height': height,
        'weight': weight,
      });
      await OnboardingService.instance.setProfileStatus('completed');

      if (mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const GerdQIntroPage()));
      }
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat terhubung ke server.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _skipProfile() async {
    try {
      await OnboardingService.instance.setProfileStatus('skipped');
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const GerdQIntroPage()),
        (route) => false,
      );
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat menyimpan status onboarding.'),
          ),
        );
      }
    }
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final height = _parseMeasurement(_heightController.text);
    final weight = _parseMeasurement(_weightController.text);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            ProfileHeader(onSkip: _skipProfile),
            if (_isLoadingProfile) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    children: [
                      const ProfileIntroCard(),
                      const SizedBox(height: 20),
                      ProfileFormCard(
                        nameController: _nameController,
                        heightController: _heightController,
                        weightController: _weightController,
                        birthDate: _birthDate,
                        gender: _gender,
                        onBirthDateTap: _selectBirthDate,
                        onGenderChanged: (value) =>
                            setState(() => _gender = value),
                      ),
                      const SizedBox(height: 20),
                      BmiCard(height: height, weight: weight),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Lanjut'),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 18),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const AuthPrivacyNote(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
