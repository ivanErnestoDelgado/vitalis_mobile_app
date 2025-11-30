import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/reminders_provider.dart';
import '../../data/models/reminder.dart';
import '../../data/models/drug.dart';
import '../../data/models/drug_variant.dart';
import '../../providers/medication_provider.dart';

class ReminderDetailScreen extends ConsumerWidget {
  final int reminderId;

  const ReminderDetailScreen({super.key, required this.reminderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderAsync = ref.watch(reminderByIdProvider(reminderId));
    final medicationsAsync = ref.watch(medicationControllerProvider);
    final drugsAsync = ref.watch(drugCatalogProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade400],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Detalle del Recordatorio",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () => context.push('/reminders/$reminderId/edit'),
                ),
              ],
            ),
          ),
        ),
      ),

      body: reminderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (reminder) {
          if (!medicationsAsync.hasValue || !drugsAsync.hasValue) {
            return const Center(child: CircularProgressIndicator());
          }

          final medications = medicationsAsync.value!;
          final drugs = drugsAsync.value!;
          final medication = medications.firstWhere(
            (m) => m.id == reminder.medication,
          );

          DrugVariant? variant;
          final drug = drugs.firstWhere((d) {
            for (final v in d.variants) {
              if (v.id == medication.drugVariant) {
                variant = v;
                return true;
              }
            }
            return false;
          });

          return _DetailContent(
            reminder: reminder,
            drug: drug,
            variant: variant!,
            onDelete: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Eliminar Recordatorio"),
                  content: const Text(
                    "¿Seguro que deseas eliminar este recordatorio?",
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Cancelar"),
                      onPressed: () => Navigator.pop(ctx, false),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Eliminar"),
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ref
                    .read(remindersNotifierProvider.notifier)
                    .deleteReminder(reminder.id);
                context.pop(); // salir al listado
              }
            },
          );
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final Reminder reminder;
  final Drug drug;
  final DrugVariant variant;
  final VoidCallback onDelete;

  const _DetailContent({
    required this.reminder,
    required this.drug,
    required this.variant,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícono superior
              Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.alarm,
                    color: Colors.blue.shade700,
                    size: 38,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                reminder.title,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),
              Text(
                reminder.message,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),

              const SizedBox(height: 25),
              _info("Frecuencia", reminder.frequency),
              _info("Inicio", reminder.startTime.toString()),
              _info(
                "Medicamento",
                "${drug.name} - ${variant.variantName} ${variant.dosage}",
              ),

              if (reminder.intervalHours != null)
                _info("Intervalo", "${reminder.intervalHours} horas"),

              const SizedBox(height: 20),
              Chip(
                label: Text(
                  reminder.isActive ? "Activo" : "Inactivo",
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: reminder.isActive ? Colors.green : Colors.red,
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Botón eliminar
        ElevatedButton.icon(
          icon: const Icon(Icons.delete_outline),
          label: const Text("Eliminar Recordatorio"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: onDelete,
        ),
      ],
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // IMPORTANTE para textos largos
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              softWrap: true,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }
}
