import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/reminders_provider.dart';
import '../globalWIdgets/medication_selector.dart';

class ReminderEditScreen extends ConsumerStatefulWidget {
  final int reminderId;

  const ReminderEditScreen({super.key, required this.reminderId});

  @override
  ConsumerState<ReminderEditScreen> createState() => _ReminderEditScreenState();
}

class _ReminderEditScreenState extends ConsumerState<ReminderEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final msgCtrl = TextEditingController();
  final intervalCtrl = TextEditingController();

  DateTime? selectedDate;
  int? selectedMedicationId;
  String frequency = "daily";

  bool initialLoaded = false;

  Color get vitalisBlue => const Color(0xFF1E88E5);
  Color get vitalisLightBlue => const Color(0xFFE3F2FD);

  @override
  void dispose() {
    titleCtrl.dispose();
    msgCtrl.dispose();
    intervalCtrl.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: selectedDate ?? now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: vitalisBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteColor: vitalisLightBlue,
              dialHandColor: vitalisBlue,
              dialBackgroundColor: vitalisLightBlue,
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
    final reminderAsync = ref.watch(reminderByIdProvider(widget.reminderId));

    return Scaffold(
      backgroundColor: vitalisLightBlue,
      appBar: AppBar(
        title: const Text(
          "Editar Recordatorio",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: vitalisBlue,
        elevation: 0,
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: vitalisBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.save),
            label: const Text("Actualizar", style: TextStyle(fontSize: 16)),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              if (selectedDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Selecciona fecha/hora")),
                );
                return;
              }

              if (selectedMedicationId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Selecciona una medicación")),
                );
                return;
              }

              await ref
                  .read(remindersNotifierProvider.notifier)
                  .updateReminder(
                    id: widget.reminderId,
                    title: titleCtrl.text,
                    message: msgCtrl.text,
                    startTime: selectedDate!,
                    frequency: frequency,
                    intervalHours: frequency == "custom"
                        ? int.parse(intervalCtrl.text)
                        : null,
                    medication: selectedMedicationId!,
                  );
              ref.invalidate(reminderByIdProvider(widget.reminderId));
              context.pop();
            },
          ),
        ),
      ),

      body: reminderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (reminder) {
          if (!initialLoaded) {
            titleCtrl.text = reminder.title;
            msgCtrl.text = reminder.message;
            frequency = reminder.frequency;
            selectedMedicationId = reminder.medication;
            selectedDate = reminder.startTime;

            if (reminder.intervalHours != null) {
              intervalCtrl.text = reminder.intervalHours.toString();
            }

            initialLoaded = true;
          }

          return _buildForm(context);
        },
      ),
    );
  }

  // ============================================================
  //                       FORM UI
  // ============================================================

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _vitalisCard(
              child: Column(
                children: [
                  _vitalisTitle("Información básica"),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: _inputDecoration(
                      label: "Título del recordatorio",
                      icon: Icons.title,
                    ),
                    validator: (v) =>
                        v!.isEmpty ? "El título es obligatorio" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: msgCtrl,
                    decoration: _inputDecoration(
                      label: "Mensaje",
                      icon: Icons.message,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            _vitalisCard(
              child: Column(
                children: [
                  _vitalisTitle("Programación"),
                  const SizedBox(height: 12),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.calendar_month, color: vitalisBlue),
                    title: Text(
                      selectedDate == null
                          ? "Selecciona fecha y hora"
                          : "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day} "
                                "${selectedDate!.hour.toString().padLeft(2, '0')}:${selectedDate!.minute.toString().padLeft(2, '0')}",
                    ),
                    trailing: Icon(Icons.edit_calendar, color: vitalisBlue),
                    onTap: pickDate,
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: frequency,
                    decoration: _inputDecoration(
                      label: "Frecuencia",
                      icon: Icons.repeat,
                    ),
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
                                decoration: _inputDecoration(
                                  label: "Intervalo (horas)",
                                  icon: Icons.timer,
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (frequency == "custom" &&
                                      (v == null || v.isEmpty)) {
                                    return "Requerido";
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

            const SizedBox(height: 18),

            _vitalisCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _vitalisTitle("Medicación"),
                  const SizedBox(height: 12),
                  MedicationSelector(
                    selectedId: selectedMedicationId,
                    onSelected: (id) =>
                        setState(() => selectedMedicationId = id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //                     UI HELPERS
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: vitalisBlue),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: vitalisBlue, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Widget _vitalisCard({required Widget child}) {
    return Card(
      elevation: 3,
      shadowColor: vitalisBlue.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  Widget _vitalisTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: vitalisBlue,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}
