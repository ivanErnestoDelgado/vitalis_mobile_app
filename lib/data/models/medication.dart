class Medication {
  final int id;
  final String dosageInstructions;
  final String startDate; // yyyy-MM-dd
  final String endDate; // yyyy-MM-dd
  final String createdAt;
  final bool createdByPatient;
  final int? doctor; // nullable
  final int patient;
  final int drugVariant;

  Medication({
    required this.id,
    required this.dosageInstructions,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.createdByPatient,
    required this.doctor,
    required this.patient,
    required this.drugVariant,
  });

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    id: json['id'],
    dosageInstructions: json['dosage_instructions'] ?? '',
    startDate: json['start_date'] ?? '',
    endDate: json['end_date'] ?? '',
    createdAt: json['created_at'] ?? '',
    createdByPatient: json['created_by_patient'] ?? false,
    doctor: json['doctor'],
    patient: json['patient'],
    drugVariant: json['drug_variant'],
  );
}
