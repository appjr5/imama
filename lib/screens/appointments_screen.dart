import 'package:flutter/material.dart';
import '../theme/strings_sw.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder list — wire this up to your backend's /appointments
    // endpoint the same way ChatScreen uses ApiService.
    final demoAppointments = [
      {'title': 'Ukaguzi wa Kliniki', 'date': 'Jumatatu, Wiki ijayo'},
      {'title': 'Chanjo ya Ujauzito', 'date': 'Wiki 2 zijazo'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text(StringsSw.appointmentsCardTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: demoAppointments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => Card(
          child: ListTile(
            leading: const Icon(Icons.event_available),
            title: Text(demoAppointments[i]['title']!),
            subtitle: Text(demoAppointments[i]['date']!),
          ),
        ),
      ),
    );
  }
}
