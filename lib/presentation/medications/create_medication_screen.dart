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

    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 650;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FA),
      appBar: AppBar(
        title: const Text(
          "Nueva Medicación",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFF1E88E5),
        elevation: 4,
      ),

      body: SafeArea(
        child: drugsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) => Center(child: Text("Error: $err")),
          data: (drugs) {
            return LayoutBuilder(
              builder: (_, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                      minHeight: constraints.maxHeight - 40,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _title("Selecciona el medicamento"),

                          _vitalisSection(
                            child: SizedBox(
                              width: double.infinity,
                              child: DropdownButtonFormField<Drug>(
                                isExpanded: true,
                                initialValue: selectedDrug,
                                decoration: const InputDecoration(
                                  labelText: "Medicamento",
                                  prefixIcon: Icon(Icons.medication_outlined),
                                ),
                                items: drugs
                                    .map(
                                      (d) => DropdownMenuItem(
                                        value: d,
                                        child: Text(
                                          d.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
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
                          ),

                          const SizedBox(height: 20),

                          if (selectedDrug != null) ...[
                            _title("Variante"),

                            _vitalisSection(
                              child: SizedBox(
                                width: double.infinity,
                                child: DropdownButtonFormField<DrugVariant>(
                                  isExpanded: true,
                                  initialValue: selectedVariant,
                                  decoration: const InputDecoration(
                                    labelText: "Variante",
                                    prefixIcon: Icon(
                                      Icons.medical_services_outlined,
                                    ),
                                  ),
                                  items: selectedDrug!.variants
                                      .map(
                                        (v) => DropdownMenuItem(
                                          value: v,
                                          child: Text(
                                            "${v.variantName} — ${v.dosage}",
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    setState(() => selectedVariant = v);
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],

                          _title("Instrucciones"),

                          _vitalisSection(
                            child: TextFormField(
                              controller: dosageCtrl,
                              maxLines: isSmall ? 2 : 3,
                              decoration: const InputDecoration(
                                labelText: "Instrucciones",
                                prefixIcon: Icon(Icons.edit_note_outlined),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          _title("Rango de fechas"),

                          Row(
                            children: [
                              Expanded(
                                child: _vitalisSection(
                                  child: ListTile(
                                    onTap: _pickStart,
                                    leading: const Icon(Icons.calendar_month),
                                    title: Text(
                                      startDate == null
                                          ? "Inicio"
                                          : DateFormat.yMd().format(startDate!),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _vitalisSection(
                                  child: ListTile(
                                    onTap: _pickEnd,
                                    leading: const Icon(Icons.event),
                                    title: Text(
                                      endDate == null
                                          ? "Fin"
                                          : DateFormat.yMd().format(endDate!),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          SizedBox(height: isSmall ? 15 : 30),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1E88E5),
                              minimumSize: const Size(double.infinity, 54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            onPressed: () => _saveMedication(auth),
                            child: const Text(
                              "Guardar",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// UI Helpers -----------------------------------------------------

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E88E5),
        ),
      ),
    );
  }

  Widget _vitalisSection({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Colors.black12,
          ),
        ],
      ),
      child: child,
    );
  }

  /// Date Pickers ----------------------------------------------------

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

  /// Save -----------------------------------------------------------

  void _saveMedication(auth) async {
    if (selectedVariant == null ||
        auth == null ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La fecha final no puede ser anterior a la inicial"),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Medicación creada")));
    }
  }
}
