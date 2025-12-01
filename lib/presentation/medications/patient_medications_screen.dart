import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/medication_provider.dart';
import '../../data/models/medication.dart';
import 'package:intl/intl.dart';

class PatientMedicationsScreen extends ConsumerWidget {
  const PatientMedicationsScreen({super.key});

  bool _canDelete(Medication m) {
    if (m.createdByPatient) return true;
    try {
      final end = DateTime.parse(m.endDate);
      return DateTime.now().isAfter(end);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medsState = ref.watch(medicationControllerProvider);
    final drugCatalog = ref.watch(drugCatalogProvider);

    return medsState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, st) => Scaffold(
        appBar: AppBar(
          title: const Text("Medicaciones"),
          backgroundColor: const Color(0xFF1E88E5),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(child: Text("Error: $err")),
      ),
      data: (list) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F9FA),
          appBar: AppBar(
            title: const Text("Medicaciones"),
            backgroundColor: const Color(0xFF1E88E5),
            elevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    ref.read(medicationControllerProvider.notifier).refresh(),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => context.push('/medications/create'),
              ),
            ],
          ),
          body: drugCatalog.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text("Error cargando catálogo")),
            data: (drugs) {
              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    "No hay medicaciones registradas",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                );
              }

              String drugInfo(Medication m) {
                final variant = drugs
                    .expand((d) => d.variants)
                    .firstWhere((v) => v.id == m.drugVariant);

                final drug = drugs.firstWhere((d) => d.id == variant.drug);

                return "${drug.name} — ${variant.variantName} (${variant.dosage})";
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) {
                  final m = list[i];

                  return TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, v, child) => Opacity(
                      opacity: v,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - v)),
                        child: child,
                      ),
                    ),
                    child: _MedicationCard(
                      medication: m,
                      drugText: drugInfo(m),
                      canDelete: _canDelete(m),
                      onDelete: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Eliminar medicación"),
                            content: const Text(
                              "¿Estás seguro de eliminar esta medicación?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancelar"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Eliminar"),
                              ),
                            ],
                          ),
                        );

                        if (ok == true) {
                          await ref
                              .read(medicationControllerProvider.notifier)
                              .deleteMedication(m.id);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Medicación eliminada"),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication medication;
  final String drugText;
  final bool canDelete;
  final VoidCallback onDelete;

  const _MedicationCard({
    required this.medication,
    required this.drugText,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final start = DateFormat.yMMMd().format(
      DateTime.parse(medication.startDate),
    );
    final end = DateFormat.yMMMd().format(DateTime.parse(medication.endDate));
    final created = DateFormat.yMMMd().add_Hm().format(
      DateTime.parse(medication.createdAt),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF1E88E5).withOpacity(0.2),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              drugText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E88E5),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              medication.dosageInstructions,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF1E88E5),
                ),
                const SizedBox(width: 6),
                Text("Inicio: $start"),
                const SizedBox(width: 14),
                Text("Fin: $end"),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              "Creado el: $created",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
