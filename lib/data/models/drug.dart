import 'drug_variant.dart';

class Drug {
  final int id;
  final String name;
  final String description;
  final bool prescriptionRequired;
  final DateTime createdAt;
  final List<DrugVariant> variants;

  Drug({
    required this.id,
    required this.name,
    required this.description,
    required this.prescriptionRequired,
    required this.createdAt,
    required this.variants,
  });

  factory Drug.fromJson(Map<String, dynamic> json) => Drug(
    id: json['id'],
    name: json['name'],
    description: json['description'] ?? '',
    prescriptionRequired: json['prescription_required'] ?? false,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at']).toLocal()
        : DateTime.now(),
    variants:
        (json['variants'] as List<dynamic>?)
            ?.map((v) => DrugVariant.fromJson(v as Map<String, dynamic>))
            .toList() ??
        [],
  );
}
