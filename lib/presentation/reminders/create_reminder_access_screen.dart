import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalis_mobile_app/data/models/reminder.dart';
import '../../providers/reminder_access_provider.dart';
import '../../providers/reminders_provider.dart';
import '../globalWIdgets/shared_access_selector.dart';

class CreateReminderAccessScreen extends ConsumerStatefulWidget {
  final int reminderId;

  const CreateReminderAccessScreen({super.key, required this.reminderId});

  @override
  ConsumerState<CreateReminderAccessScreen> createState() =>
      _CreateReminderAccessScreenState();
}

class _CreateReminderAccessScreenState
    extends ConsumerState<CreateReminderAccessScreen> {
  int? selectedUserProfileId; // ya NO usamos sharedAccessId

  @override
  Widget build(BuildContext context) {
    final reminderAsync = ref.watch(reminderByIdProvider(widget.reminderId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          "Dar acceso al recordatorio",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: reminderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error al cargar recordatorio")),
        data: (reminder) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReminderInfoCard(reminder: reminder),

                const SizedBox(height: 24),

                SharedAccessSelector(
                  selectedId: selectedUserProfileId,
                  onSelected: (userProfileId) =>
                      setState(() => selectedUserProfileId = userProfileId),
                  mode: "patient",
                ),

                const SizedBox(height: 40),

                _buildSubmitButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final isDisabled = selectedUserProfileId == null;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isDisabled
            ? null
            : () async {
                await ref
                    .read(reminderAccessNotifierProvider.notifier)
                    .create(
                      reminderId: widget.reminderId,
                      userId: selectedUserProfileId!,
                    );

                if (mounted) Navigator.pop(context);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? Colors.grey.shade400
              : const Color(0xFF1976D2),
          disabledBackgroundColor: Colors.grey.shade400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 3,
        ),
        child: const Text(
          "Agregar acceso",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// =======================================================
/// TARJETA DEL RECORDATORIO
/// =======================================================

class _ReminderInfoCard extends StatelessWidget {
  final Reminder reminder;

  const _ReminderInfoCard({required this.reminder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Información del recordatorio",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.notifications_active, color: Color(0xFF1976D2)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reminder.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(reminder.message, style: TextStyle(color: Colors.grey.shade700)),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.schedule, color: Color(0xFF0D47A1)),
              const SizedBox(width: 8),
              Text(
                "Inicio: ${reminder.startTime}",
                style: TextStyle(color: Colors.grey.shade800),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.repeat, color: Color(0xFF0D47A1)),
              const SizedBox(width: 8),
              Text(
                "Frecuencia: ${reminder.frequency}",
                style: TextStyle(color: Colors.grey.shade800),
              ),
            ],
          ),

          if (reminder.intervalHours != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.timelapse, color: Color(0xFF0D47A1)),
                const SizedBox(width: 8),
                Text(
                  "Intervalo: cada ${reminder.intervalHours}h",
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
