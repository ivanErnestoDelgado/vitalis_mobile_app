import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/medication_provider.dart';
import '../../data/models/medication.dart';
import 'create_medication_screen.dart';
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

    return medsState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, st) => Scaffold(
        appBar: AppBar(
          title: const Text("Medicaciones"),
          backgroundColor: const Color(0xFF0A8EA0),
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => context.go('/home'), // ← AQUÍ
            ),
          ],
        ),
        body: Center(child: Text("Error: $err")),
      ),
      data: (list) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F9FA),
          appBar: AppBar(
            title: const Text("Medicaciones"),
            backgroundColor: const Color(0xFF0A8EA0),
            elevation: 2,
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => context.go('/home'), // ← NUEVO BOTÓN
              ),
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
              ? const Center(
                  child: Text(
                    "No hay medicaciones registradas",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final m = list[i];

                    return TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 350),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            m.dosageInstructions,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            "Inicio: ${m.startDate} — Fin: ${m.endDate}\n"
                            "Creado: ${DateFormat.yMd().add_Hm().format(DateTime.parse(m.createdAt))}",
                          ),
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
                                        title: const Text(
                                          "Eliminar medicación",
                                        ),
                                        content: const Text(
                                          "¿Estás seguro de eliminar esta medicación?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Cancelar"),
                                          ),
                                          ElevatedButton(
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
                                            medicationControllerProvider
                                                .notifier,
                                          )
                                          .deleteMedication(m.id);

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Medicación eliminada"),
                                        ),
                                      );
                                    }
                                  },
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
