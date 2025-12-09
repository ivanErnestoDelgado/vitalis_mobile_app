class Reminder {
  final int id;
  final int patient;
  final String patientEmail;
  final String patientFirstName;
  final String patientLastName;
  final int? medication;
  final String title;
  final String message;
  final DateTime startTime;
  final String frequency;
  final int? intervalHours;
  final bool isActive;
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.patient,
    required this.patientEmail,
    required this.patientFirstName,
    required this.patientLastName,
    required this.medication,
    required this.title,
    required this.message,
    required this.startTime,
    required this.frequency,
    required this.intervalHours,
    required this.isActive,
    required this.createdAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    id: json['id'],
    patient: json['patient'],
    patientEmail: json['patient_email'],
    patientFirstName: json['patient_name'],
    patientLastName: json['patient_last_name'],
    medication: json['medication'],
    title: json['title'],
    message: json['message'],
    startTime: DateTime.parse(json['start_time']).toLocal(),
    frequency: json['frequency'],
    intervalHours: json['interval_hours'],
    isActive: json['is_active'],
    createdAt: DateTime.parse(json['created_at']).toLocal(),
  );
}
