import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/medication_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/drug.dart';
import '../../data/models/drug_variant.dart';
import 'package:intl/intl.dart';

class CreateMedicationScreen extends ConsumerStatefulWidget {
  const CreateMedicationScreen({super.key});

  @override
  ConsumerState<CreateMedicationScreen> createState() =>
      _CreateMedicationScreenState();
}

class _CreateMedicationScreenState
    extends ConsumerState<CreateMedicationScreen> {
  Drug? selectedDrug;
  DrugVariant? selectedVariant;
  final dosageCtrl = TextEditingController(
    text: "Tomar 1 tableta cada 8 horas",
  );

  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    final drugsAsync = ref.watch(drugCatalogProvider);
    final auth = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FA),
      appBar: AppBar(
        title: const Text("Nueva Medicación"),
        backgroundColor: const Color(0xFF0A8EA0),
      ),
      body: drugsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text("Error: $err")),
        data: (drugs) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _vitalisCard(
                  child: DropdownButtonFormField<Drug>(
                    value: selectedDrug,
                    decoration: const InputDecoration(labelText: "Medicamento"),
                    items: drugs
                        .map(
                          (d) =>
                              DropdownMenuItem(value: d, child: Text(d.name)),
                        )
                        .toList(),
                    onChanged: (d) {
                      setState(() {
                        selectedDrug = d;
                        selectedVariant = null;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                if (selectedDrug != null)
                  _vitalisCard(
                    child: DropdownButtonFormField<DrugVariant>(
                      value: selectedVariant,
                      decoration: const InputDecoration(labelText: "Variante"),
                      items: selectedDrug!.variants
                          .map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child: Text("${v.variantName} — ${v.dosage}"),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedVariant = v),
                    ),
                  ),

                const SizedBox(height: 16),

                _vitalisCard(
                  child: TextFormField(
                    controller: dosageCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "Instrucciones",
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _vitalisCard(
                        child: TextButton(
                          onPressed: _pickStart,
                          child: Text(
                            startDate == null
                                ? "Fecha inicio"
                                : DateFormat.yMd().format(startDate!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _vitalisCard(
                        child: TextButton(
                          onPressed: _pickEnd,
                          child: Text(
                            endDate == null
                                ? "Fecha fin"
                                : DateFormat.yMd().format(endDate!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A8EA0),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    if (selectedVariant == null ||
                        auth == null ||
                        startDate == null ||
                        endDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Completa todos los campos"),
                        ),
                      );
                      return;
                    }

                    if (endDate!.isBefore(startDate!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "La fecha final no puede ser anterior a la inicial",
                          ),
                        ),
                      );
                      return;
                    }

                    String f(DateTime d) =>
                        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

                    await ref
                        .read(medicationControllerProvider.notifier)
                        .createMedication(
                          patient: auth.id,
                          drugVariant: selectedVariant!.id,
                          dosageInstructions: dosageCtrl.text.trim(),
                          startDate: f(startDate!),
                          endDate: f(endDate!),
                        );

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Medicación creada")),
                      );
                    }
                  },
                  child: const Text("Guardar", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final dt = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (dt != null) setState(() => startDate = dt);
  }

  Future<void> _pickEnd() async {
    final now = DateTime.now();
    final dt = await showDatePicker(
      context: context,
      initialDate: startDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (dt != null) setState(() => endDate = dt);
  }

  Widget _vitalisCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(blurRadius: 8, offset: Offset(0, 3), color: Colors.black12),
        ],
      ),
      child: child,
    );
  }
}
