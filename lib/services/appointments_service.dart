import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';

class AppointmentsService {
  static const _key = 'appointments';

  static Future<List<Appointment>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    final appts = list.map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
    appts.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return appts;
  }

  static Future<void> add(Appointment appt) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.add(appt);
    await prefs.setString(_key, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  static Future<void> update(Appointment updated) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    final idx = all.indexWhere((a) => a.id == updated.id);
    if (idx >= 0) all[idx] = updated;
    await prefs.setString(_key, jsonEncode(all.map((e) => e.toJson()).toList()));
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.removeWhere((a) => a.id == id);
    await prefs.setString(_key, jsonEncode(all.map((e) => e.toJson()).toList()));
  }
}
