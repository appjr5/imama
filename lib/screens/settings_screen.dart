import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
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
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await ProfileService.getProfile();
    _nameController.text = profile.name;
    _phoneController.text = profile.phone;
    _weeksController.text = profile.pregnancyWeeks == 0 ? '' : '${profile.pregnancyWeeks}';
    _dueDateController.text = profile.dueDate;
    _weightController.text = profile.weightKg == 0 ? '' : '${profile.weightKg}';
    _heightController.text = profile.heightCm == 0 ? '' : '${profile.heightCm}';
    _kidsController.text = '${profile.numberOfKids}';
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 300)),
      helpText: 'Chagua tarehe ya kujifungua',
    );
    if (picked != null) {
      _dueDateController.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  Future<void> _save() async {
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
    await ProfileService.updateProfile(profile);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(StringsSw.savedMessage)));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text(StringsSw.settingsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: StringsSw.nameLabel)),
            const SizedBox(height: 12),
            TextField(controller: _phoneController, keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: StringsSw.phoneLabel)),
            const SizedBox(height: 12),
            TextField(controller: _weeksController, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: StringsSw.weeksLabel)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dueDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: StringsSw.dueDateLabel,
                suffixIcon: IconButton(icon: const Icon(Icons.calendar_month_outlined), onPressed: _pickDueDate),
              ),
              onTap: _pickDueDate,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Uzito (kg)')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Urefu (cm)')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _kidsController, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Idadi ya Watoto Uliyonao')),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text(StringsSw.saveButton),
            ),
          ],
        ),
      ),
    );
  }
}
