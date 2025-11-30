import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/medication_provider.dart';
import '../../data/models/medication.dart';

class MedicationSelector extends ConsumerWidget {
  final int? selectedId;
  final void Function(int medicationId) onSelected;

  const MedicationSelector({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationControllerProvider);
    final drugs = ref.watch(drugCatalogProvider);

    return medications.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Error al cargar medicaciones")),
      data: (items) {
        return drugs.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text("Error cargando catálogo de medicinas"),
          data: (catalog) {
            if (items.isEmpty) {
              return const Center(
                child: Text("No tienes medicaciones registradas"),
              );
            }

            String resolveVariantName(int variantId) {
              for (final drug in catalog) {
                for (final variant in drug.variants) {
                  if (variant.id == variantId) {
                    return "${drug.name}-${variant.variantName}";
                  }
                }
              }
              return "Variante #$variantId";
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selecciona una medicación",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 12),

                ...items.map(
                  (m) => _MedicationItem(
                    medication: m,
                    variantName: resolveVariantName(m.drugVariant),
                    selected: selectedId == m.id,
                    onTap: () => onSelected(m.id),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _MedicationItem extends StatelessWidget {
  final Medication medication;
  final String variantName;
  final bool selected;
  final VoidCallback onTap;

  const _MedicationItem({
    required this.medication,
    required this.variantName,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFE3F2FD) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? const Color(0xFF2196F3) : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          variantName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Dosis: ${medication.dosageInstructions}\n"
          "Hasta: ${medication.endDate}",
        ),
        trailing: selected
            ? const Icon(Icons.check_circle, color: Color(0xFF2196F3), size: 28)
            : const Icon(Icons.circle_outlined, color: Colors.grey),
      ),
    );
  }
}
