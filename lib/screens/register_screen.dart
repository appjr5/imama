import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../theme/strings_sw.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _weeksController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _kidsController = TextEditingController(text: '0');
  bool _saving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final profile = UserProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      pregnancyWeeks: int.tryParse(_weeksController.text.trim()) ?? 0,
      dueDate: _dueDateController.text.trim(),
      weightKg: double.tryParse(_weightController.text.trim()) ?? 0,
      heightCm: double.tryParse(_heightController.text.trim()) ?? 0,
      numberOfKids: int.tryParse(_kidsController.text.trim()) ?? 0,
    );
    await SettingsService.saveProfile(profile);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.favorite, color: AppTheme.primaryPurple, size: 48),
                  const SizedBox(height: 12),
                  const Text('Karibu iMama',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text('Tujaze taarifa zako ili tukusaidie vizuri zaidi.',
                      style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: StringsSw.nameLabel),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Jaza jina' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: StringsSw.phoneLabel),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _weeksController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: StringsSw.weeksLabel),
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null || n <= 0 || n > 42) return 'Weka wiki sahihi (1-42)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dueDateController,
                    decoration: const InputDecoration(labelText: StringsSw.dueDateLabel),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Uzito (kg)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Urefu (cm)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _kidsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Idadi ya Watoto Uliyonao'),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Anza'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
