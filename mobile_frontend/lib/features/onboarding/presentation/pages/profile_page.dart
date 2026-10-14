import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/auth_privacy_note.dart';
import '../../../home/presentation/pages/home_page.dart';
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
  String _gender = 'Laki-laki';

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_refresh);
    _heightController.addListener(_refresh);
    _weightController.addListener(_refresh);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

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
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          ProfileHeader(
            onSkip: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const HomePage()),
              (route) => false,
            ),
          ),
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
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const GerdQIntroPage(),
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        child: const Row(
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
    );
  }
}
