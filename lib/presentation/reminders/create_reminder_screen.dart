import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/reminders_provider.dart';
import '../globalWIdgets/medication_selector.dart';

class ReminderCreateScreen extends ConsumerStatefulWidget {
  const ReminderCreateScreen({super.key});

  @override
  ConsumerState<ReminderCreateScreen> createState() =>
      _ReminderCreateScreenState();
}

class _ReminderCreateScreenState extends ConsumerState<ReminderCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final msgCtrl = TextEditingController();
  final intervalCtrl = TextEditingController();

  DateTime? selectedDate;
  int? selectedMedicationId;
  String frequency = "daily";

  static const primaryBlue = Color(0xFF1565C0);
  static const softBlue = Color(0xFFE3F2FD);

  Future<void> pickDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      helpText: "Selecciona la fecha",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    setState(() {
      selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softBlue,

      appBar: AppBar(
        title: const Text(
          "Crear Recordatorio",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 1,
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(18),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save, color: Colors.white),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 3,
            ),
            label: const Text(
              "Guardar Recordatorio",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              if (selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Selecciona fecha y hora")),
                );
                return;
              }

              if (selectedMedicationId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Selecciona una medicación")),
                );
                return;
              }

              try {
                await ref
                    .read(remindersNotifierProvider.notifier)
                    .createReminder(
                      title: titleCtrl.text,
                      message: msgCtrl.text,
                      startTime: selectedDate!,
                      frequency: frequency,
                      intervalHours: frequency == "custom"
                          ? int.parse(intervalCtrl.text)
                          : null,
                      medication: selectedMedicationId!,
                    );

                context.pop();
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _vitalisCard(
                title: "Información básica",
                child: Column(
                  children: [
                    _input(
                      controller: titleCtrl,
                      label: "Título del reminder",
                      icon: Icons.title,
                    ),
                    const SizedBox(height: 12),
                    _input(
                      controller: msgCtrl,
                      label: "Mensaje",
                      icon: Icons.message,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _vitalisCard(
                title: "Fecha y Frecuencia",
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_month,
                        color: primaryBlue,
                      ),
                      title: Text(
                        selectedDate == null
                            ? "Seleccionar fecha y hora"
                            : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} "
                                  " ${selectedDate!.hour.toString().padLeft(2, '0')}:${selectedDate!.minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: const Icon(
                        Icons.edit_calendar,
                        color: primaryBlue,
                      ),
                      onTap: pickDate,
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: frequency,
                      decoration: _inputDeco("Frecuencia", Icons.repeat),
                      items: const [
                        DropdownMenuItem(value: "daily", child: Text("Diario")),
                        DropdownMenuItem(
                          value: "custom",
                          child: Text("Cada N horas"),
                        ),
                      ],
                      onChanged: (v) => setState(() => frequency = v!),
                    ),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: frequency == "custom"
                          ? Column(
                              key: const ValueKey("custom"),
                              children: [
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: intervalCtrl,
                                  decoration: _inputDeco(
                                    "Intervalo (horas)",
                                    Icons.timer,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (frequency == "custom" &&
                                        (v == null || v.isEmpty)) {
                                      return "Requerido si es intervalo por horas";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            )
                          : const SizedBox.shrink(key: ValueKey("daily")),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _vitalisCard(
                title: "Seleccionar medicación",
                child: MedicationSelector(
                  selectedId: selectedMedicationId,
                  onSelected: (id) {
                    setState(() => selectedMedicationId = id);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------ ESTILOS AZULES -----------------------

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _inputDeco(label, icon),
      validator: (v) => v!.isEmpty ? "Campo requerido" : null,
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryBlue),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Widget _vitalisCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFBBDEFB), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
