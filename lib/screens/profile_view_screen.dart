import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../theme/strings_sw.dart';
import 'settings_screen.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final profile = await ProfileService.getProfile();
    if (mounted) setState(() { _profile = profile; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(StringsSw.profileTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              _load();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? const Center(child: Text('Imeshindikana kupata wasifu.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _InfoTile(icon: Icons.person_outline, label: StringsSw.nameLabel, value: _profile!.name),
                    _InfoTile(icon: Icons.phone_outlined, label: StringsSw.phoneLabel, value: _profile!.phone),
                    _InfoTile(
                      icon: Icons.pregnant_woman_outlined,
                      label: StringsSw.weeksLabel,
                      value: _profile!.pregnancyWeeks == 0 ? '-' : '${_profile!.pregnancyWeeks} wiki',
                    ),
                    _InfoTile(icon: Icons.event_outlined, label: StringsSw.dueDateLabel, value: _profile!.dueDate),
                    _InfoTile(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Uzito',
                      value: _profile!.weightKg == 0 ? '-' : '${_profile!.weightKg} kg',
                    ),
                    _InfoTile(
                      icon: Icons.height_outlined,
                      label: 'Urefu',
                      value: _profile!.heightCm == 0 ? '-' : '${_profile!.heightCm} cm',
                    ),
                    _InfoTile(
                      icon: Icons.family_restroom_outlined,
                      label: 'Idadi ya Watoto',
                      value: '${_profile!.numberOfKids}',
                    ),
                  ],
                ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryPurple),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        subtitle: Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
