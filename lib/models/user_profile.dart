class UserProfile {
  String name;
  String phone;
  int pregnancyWeeks;
  String dueDate;
  double weightKg;
  double heightCm;
  int numberOfKids;

  UserProfile({
    this.name = '',
    this.phone = '',
    this.pregnancyWeeks = 0,
    this.dueDate = '',
    this.weightKg = 0,
    this.heightCm = 0,
    this.numberOfKids = 0,
  });

  bool get isComplete => name.isNotEmpty && pregnancyWeeks > 0;

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'pregnancyWeeks': pregnancyWeeks,
        'dueDate': dueDate,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'numberOfKids': numberOfKids,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        pregnancyWeeks: json['pregnancyWeeks'] ?? 0,
        dueDate: json['dueDate'] ?? '',
        weightKg: (json['weightKg'] ?? 0).toDouble(),
        heightCm: (json['heightCm'] ?? 0).toDouble(),
        numberOfKids: json['numberOfKids'] ?? 0,
      );
}
