class DrugVariant {
  final int id;
  final String variantName;
  final String dosage;
  final String manufacturer;
  final bool available;
  final int drug; // parent drug id

  DrugVariant({
    required this.id,
    required this.variantName,
    required this.dosage,
    required this.manufacturer,
    required this.available,
    required this.drug,
  });

  factory DrugVariant.fromJson(Map<String, dynamic> json) => DrugVariant(
    id: json['id'],
    variantName: json['variant_name'],
    dosage: json['dosage'] ?? '',
    manufacturer: json['manufacturer'] ?? '',
    available: json['available'] ?? false,
    drug: json['drug'],
  );
}
