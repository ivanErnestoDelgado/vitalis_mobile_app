import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/medication_provider.dart';
import '../../data/models/drug.dart';
import '../../data/models/drug_variant.dart';
import 'package:intl/intl.dart';

class CreateMedicationForPatientScreen extends ConsumerStatefulWidget {
  final int patientId;

  const CreateMedicationForPatientScreen({super.key, required this.patientId});

  @override
  ConsumerState<CreateMedicationForPatientScreen> createState() =>
      _CreateMedicationForPatientScreenState();
}

class _CreateMedicationForPatientScreenState
    extends ConsumerState<CreateMedicationForPatientScreen> {
  Drug? selectedDrug;
  DrugVariant? selectedVariant;

  final dosageCtrl = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  final Color primaryBlue = const Color(0xFF1565C0);
  final Color bgColor = const Color(0xFFF4F7FB);

  @override
  Widget build(BuildContext context) {
    final drugsAsync = ref.watch(drugCatalogProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Crear Medicación",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
      ),
      body: drugsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (drugs) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Medicamento"),
              _drugDropdown(drugs),

              if (selectedDrug != null) ...[
                const SizedBox(height: 12),
                _sectionTitle("Presentación"),
                _variantDropdown(selectedDrug!.variants),
              ],

              const SizedBox(height: 20),
              _sectionTitle("Instrucciones"),
              _inputCard(
                child: TextField(
                  controller: dosageCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: "Ej. Tomar 1 tableta cada 8 horas",
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _sectionTitle("Periodo de administración"),

              Row(
                children: [
                  Expanded(
                    child: _dateSelector(
                      label: "Inicio",
                      date: startDate,
                      onTap: () async {
                        final d = await _pickDate();
                        if (d != null) setState(() => startDate = d);
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _dateSelector(
                      label: "Fin",
                      date: endDate,
                      onTap: () async {
                        final d = await _pickDate();
                        if (d != null) setState(() => endDate = d);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  //────────────────────────────────────────────
  // UI HELPERS
  //────────────────────────────────────────────

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: primaryBlue,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _inputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _drugDropdown(List<Drug> drugs) {
    return _inputCard(
      child: DropdownButton<Drug>(
        isExpanded: true,
        hint: const Text("Seleccionar medicamento"),
        value: selectedDrug,
        items: drugs
            .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
            .toList(),
        onChanged: (d) {
          setState(() {
            selectedDrug = d;
            selectedVariant = null;
          });
        },
        underline: const SizedBox(),
      ),
    );
  }

  Widget _variantDropdown(List<DrugVariant> variants) {
    return _inputCard(
      child: DropdownButton<DrugVariant>(
        isExpanded: true,
        hint: const Text("Seleccionar presentación"),
        value: selectedVariant,
        items: variants
            .map(
              (v) => DropdownMenuItem(
                value: v,
                child: Text("${v.variantName} (${v.dosage})"),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => selectedVariant = v),
        underline: const SizedBox(),
      ),
    );
  }

  Widget _dateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return _inputCard(
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date == null ? label : DateFormat("yyyy-MM-dd").format(date)),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _submitButton() {
    final isReady =
        selectedDrug != null &&
        selectedVariant != null &&
        dosageCtrl.text.isNotEmpty &&
        startDate != null &&
        endDate != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: !isReady ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          "Guardar medicación",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  //────────────────────────────────────────────
  // LOGIC
  //────────────────────────────────────────────

  Future<DateTime?> _pickDate() async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
  }

  Future<void> _submit() async {
    final controller = ref.read(medicationControllerProvider.notifier);

    await controller.createMedicationForDoctor(
      patient: widget.patientId,
      drugVariant: selectedVariant!.id,
      dosageInstructions: dosageCtrl.text.trim(),
      startDate: DateFormat("yyyy-MM-dd").format(startDate!),
      endDate: DateFormat("yyyy-MM-dd").format(endDate!),
    );

    if (mounted) Navigator.pop(context);
  }
}
