import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/appointments_service.dart';
import '../theme/strings_sw.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Appointment> _appointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await AppointmentsService.getAll();
    if (mounted) setState(() { _appointments = list; _loading = false; });
  }

  Future<void> _delete(String id) async {
    await AppointmentsService.delete(id);
    await _load();
  }

  Future<void> _openForm({Appointment? existing}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AppointmentForm(existing: existing, onSaved: _load),
    );
  }

  String _formatDateTime(DateTime dt) {
    const days = ['Jumapili', 'Jumatatu', 'Jumanne', 'Jumatano', 'Alhamisi', 'Ijumaa', 'Jumamosi'];
    const months = ['', 'Jan', 'Feb', 'Mac', 'Apr', 'Mei', 'Jun', 'Jul', 'Ago', 'Sep', 'Okt', 'Nov', 'Des'];
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '${days[dt.weekday % 7]}, ${dt.day} ${months[dt.month]} ${dt.year}  $hour:$min';
  }

  bool _isPast(DateTime dt) => dt.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text(StringsSw.appointmentsCardTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Ongeza'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_available, size: 56, color: Colors.black26),
                      SizedBox(height: 12),
                      Text('Huna ratiba yoyote bado.',
                          style: TextStyle(color: Colors.black54)),
                      SizedBox(height: 8),
                      Text('Bonyeza + ili kuongeza.', style: TextStyle(color: Colors.black38, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: _appointments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final a = _appointments[i];
                    final past = _isPast(a.dateTime);
                    return Dismissible(
                      key: ValueKey(a.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Futa Ratiba'),
                            content: Text('Futa "${a.title}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hapana')),
                              TextButton(onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Futa', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) => _delete(a.id),
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: past ? Colors.grey.shade200 : accentColor.withValues(alpha: 0.15),
                            child: Icon(
                              Icons.event_available,
                              color: past ? Colors.grey : accentColor,
                            ),
                          ),
                          title: Text(a.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: past ? Colors.grey : null,
                                decoration: past ? TextDecoration.lineThrough : null,
                              )),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_formatDateTime(a.dateTime),
                                  style: TextStyle(color: past ? Colors.grey : accentColor, fontSize: 12)),
                              if (a.notes.isNotEmpty)
                                Text(a.notes, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _openForm(existing: a),
                          ),
                          isThreeLine: a.notes.isNotEmpty,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _AppointmentForm extends StatefulWidget {
  final Appointment? existing;
  final VoidCallback onSaved;
  const _AppointmentForm({this.existing, required this.onSaved});

  @override
  State<_AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<_AppointmentForm> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _dateTime = DateTime.now().add(const Duration(days: 1));
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _titleController.text = widget.existing!.title;
      _notesController.text = widget.existing!.notes;
      _dateTime = widget.existing!.dateTime;
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dateTime));
    if (t == null) return;
    setState(() => _dateTime = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final appt = Appointment(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      dateTime: _dateTime,
      notes: _notesController.text.trim(),
    );

    if (widget.existing != null) {
      await AppointmentsService.update(appt);
    } else {
      await AppointmentsService.add(appt);
    }

    widget.onSaved();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final accentColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.existing == null ? 'Ongeza Ratiba' : 'Hariri Ratiba',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Jina la Ratiba', hintText: 'mfano: Ukaguzi wa Kliniki'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.calendar_month_outlined, color: accentColor),
            title: Text(_formatDateTime(_dateTime), style: TextStyle(color: accentColor, fontWeight: FontWeight.w600)),
            subtitle: const Text('Gusa kubadilisha tarehe na wakati'),
            onTap: _pickDate,
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Maelezo (hiari)', hintText: 'mfano: Daktari Amani, Kliniki ya Kenyatta'),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(widget.existing == null ? 'Hifadhi' : 'Sasisha'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year}  $h:$m';
  }
}
