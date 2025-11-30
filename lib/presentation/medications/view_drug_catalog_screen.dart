import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalis_mobile_app/data/models/drug.dart';
import 'package:vitalis_mobile_app/data/models/drug_variant.dart';
import '../../providers/medication_provider.dart';
import 'package:go_router/go_router.dart';

class ViewDrugCatalogScreen extends ConsumerWidget {
  const ViewDrugCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drugsAsync = ref.watch(drugCatalogProvider);

    return drugsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, st) => Scaffold(body: Center(child: Text("Error: $err"))),
      data: (drugs) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F9FA),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => context.pop(),
            ),
            title: const Text("Catálogo de Medicamentos"),
            backgroundColor: Color(0xFF1E88E5),
            elevation: 2,
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: drugs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final d = drugs[i];

              return _DrugCard(drug: d);
            },
          ),
        );
      },
    );
  }
}

class _DrugCard extends StatelessWidget {
  final Drug drug;

  const _DrugCard({required this.drug});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF1E88E5).withOpacity(0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 14,
          ),
          title: Text(
            drug.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E88E5),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (drug.prescriptionRequired)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.assignment_turned_in,
                        size: 14,
                        color: Colors.red,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Requiere receta",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                drug.description.isNotEmpty
                    ? drug.description
                    : "Sin descripción",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
          iconColor: const Color(0xFF1E88E5),
          collapsedIconColor: const Color(0xFF1E88E5),
          children: drug.variants.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "No hay variantes disponibles",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ]
              : drug.variants.map((v) => _DrugVariantTile(variant: v)).toList(),
        ),
      ),
    );
  }
}

class _DrugVariantTile extends StatelessWidget {
  final DrugVariant variant;

  const _DrugVariantTile({required this.variant});

  @override
  Widget build(BuildContext context) {
    final availableColor = variant.available
        ? Colors.green[100]
        : Colors.red[100];

    final textColor = variant.available ? Colors.green[900] : Colors.red[900];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FDFE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF0A8EA0).withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.medication_liquid,
            size: 28,
            color: const Color(0xFF1E88E5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variant.variantName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${variant.dosage} • ${variant.manufacturer}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Chip(
            backgroundColor: availableColor,
            label: Text(
              variant.available ? "Disponible" : "No disponible",
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
