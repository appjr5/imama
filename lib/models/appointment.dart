class Appointment {
  final String id;
  final String title;
  final DateTime dateTime;
  final String notes;

  Appointment({
    required this.id,
    required this.title,
    required this.dateTime,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dateTime': dateTime.toIso8601String(),
        'notes': notes,
      };

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] as String,
        title: json['title'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        notes: json['notes'] as String? ?? '',
      );
}
