import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/settings_service.dart';
import '../theme/strings_sw.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _weeksController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _kidsController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await SettingsService.getProfile();
    _nameController.text = profile.name;
    _phoneController.text = profile.phone;
    _weeksController.text = profile.pregnancyWeeks == 0 ? '' : profile.pregnancyWeeks.toString();
    _dueDateController.text = profile.dueDate;
    _weightController.text = profile.weightKg == 0 ? '' : profile.weightKg.toString();
    _heightController.text = profile.heightCm == 0 ? '' : profile.heightCm.toString();
    _kidsController.text = profile.numberOfKids.toString();
    setState(() => _loading = false);
  }

  Future<void> _save() async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(StringsSw.savedMessage)),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text(StringsSw.settingsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: StringsSw.nameLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: StringsSw.phoneLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weeksController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: StringsSw.weeksLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dueDateController,
              decoration: const InputDecoration(labelText: StringsSw.dueDateLabel),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Uzito (kg)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Urefu (cm)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _kidsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Idadi ya Watoto Uliyonao'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text(StringsSw.saveButton),
            ),
          ],
        ),
      ),
    );
  }
}
