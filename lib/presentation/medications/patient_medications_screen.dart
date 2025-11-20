import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/medication_provider.dart';
import '../../data/models/medication.dart';
import 'create_medication_screen.dart';
import 'package:intl/intl.dart';

class PatientMedicationsScreen extends ConsumerWidget {
  const PatientMedicationsScreen({super.key});

  bool _canDelete(Medication m) {
    // If created_by_patient => can delete
    if (m.createdByPatient) return true;

    // If prescribed by doctor (doctor != null) only allow delete if end_date is before today
    try {
      final end = DateTime.parse(m.endDate);
      final today = DateTime.now();
      return today.isAfter(end);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medsState = ref.watch(medicationControllerProvider);

    return medsState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, st) => Scaffold(
        appBar: AppBar(title: const Text("Medicaciones")),
        body: Center(child: Text("Error: $err")),
      ),
      data: (list) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Medicaciones"),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    ref.read(medicationControllerProvider.notifier).refresh(),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateMedicationScreen(),
                  ),
                ),
              ),
            ],
          ),
          body: list.isEmpty
              ? const Center(child: Text("No hay medicaciones"))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (_, i) {
                    final m = list[i];
                    return Card(
                      child: ListTile(
                        title: Text(m.dosageInstructions),
                        subtitle: Text(
                          "Inicio: ${m.startDate} — Fin: ${m.endDate}\nCreado: ${DateFormat.yMd().add_Hm().format(DateTime.parse(m.createdAt))}",
                        ),
                        isThreeLine: true,
                        trailing: _canDelete(m)
                            ? IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Eliminar medicación"),
                                      content: const Text(
                                        "¿Seguro que deseas eliminar esta medicación?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text("Cancelar"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text("Eliminar"),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (ok == true) {
                                    await ref
                                        .read(
                                          medicationControllerProvider.notifier,
                                        )
                                        .deleteMedication(m.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Medicación eliminada"),
                                      ),
                                    );
                                  }
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: list.length,
                ),
        );
      },
    );
  }
}
