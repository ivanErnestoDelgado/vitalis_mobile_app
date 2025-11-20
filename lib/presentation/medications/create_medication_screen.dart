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

  bool loadingDrugs = true;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() => loadingDrugs = true);
    try {
      await ref.refresh(drugCatalogProvider.future);
    } finally {
      if (mounted) setState(() => loadingDrugs = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final drugsAsync = ref.watch(drugCatalogProvider);
    final auth = ref.watch(authStateProvider).value;

    return drugsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, st) => Scaffold(body: Center(child: Text("Error: $err"))),
      data: (drugs) {
        return Scaffold(
          appBar: AppBar(title: const Text("Crear medicación")),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<Drug>(
                  initialValue: selectedDrug,
                  items: drugs
                      .map(
                        (d) => DropdownMenuItem(value: d, child: Text(d.name)),
                      )
                      .toList(),
                  onChanged: (d) {
                    setState(() {
                      selectedDrug = d;
                      selectedVariant = null;
                    });
                  },
                  decoration: const InputDecoration(labelText: "Medicamento"),
                ),

                const SizedBox(height: 12),

                if (selectedDrug != null)
                  DropdownButtonFormField<DrugVariant>(
                    value: selectedVariant,
                    items: selectedDrug!.variants
                        .map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text("${v.variantName} — ${v.dosage}"),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedVariant = v),
                    decoration: const InputDecoration(labelText: "Variante"),
                  ),

                const SizedBox(height: 12),
                TextFormField(
                  controller: dosageCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: "Instrucciones"),
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _pickStart,
                        child: Text(
                          startDate == null
                              ? "Fecha inicio"
                              : DateFormat.yMd().format(startDate!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _pickEnd,
                        child: Text(
                          endDate == null
                              ? "Fecha fin"
                              : DateFormat.yMd().format(endDate!),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ElevatedButton(
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

                    // formato yyyy-MM-dd
                    final sdf = (DateTime d) =>
                        "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

                    await ref
                        .read(medicationControllerProvider.notifier)
                        .createMedication(
                          patient: auth.id,
                          drugVariant: selectedVariant!.id,
                          dosageInstructions: dosageCtrl.text.trim(),
                          startDate: sdf(startDate!),
                          endDate: sdf(endDate!),
                        );

                    // go back and refresh list
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Medicación creada")),
                      );
                    }
                  },
                  child: const Text("Crear"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
