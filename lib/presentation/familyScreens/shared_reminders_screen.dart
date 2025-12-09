import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reminders_provider.dart';
import '../../providers/auth_provider.dart';

class SharedRemindersScreen extends ConsumerWidget {
  const SharedRemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersNotifierProvider);
    final auth = ref.watch(authStateProvider).value;

    const primaryBlue = Color(0xFF1976D2);
    const bgColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: const Text(
          "Recordatorios Compartidos",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: remindersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (reminders) {
          if (auth == null) {
            return const Center(child: Text("No autenticado."));
          }

          final sharedReminders = reminders
              .where((r) => r.patient != auth.id)
              .toList();

          if (sharedReminders.isEmpty) {
            return const Center(
              child: Text(
                "No tienes recordatorios compartidos.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sharedReminders.length,
            itemBuilder: (context, i) {
              final r = sharedReminders[i];

              return _ReminderCard(reminder: r, color: primaryBlue);
            },
          );
        },
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Color color;
  final reminder;

  const _ReminderCard({required this.reminder, required this.color});

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  radius: 26,
                  child: Icon(Icons.notifications, color: color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    reminder.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Datos del paciente
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.black54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${reminder.patientFirstName} ${reminder.patientLastName}",
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 18,
                  color: Colors.black54,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    reminder.patientEmail,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Frecuencia
            Row(
              children: [
                const Icon(Icons.repeat, size: 18, color: Colors.black54),
                const SizedBox(width: 6),
                Text(
                  "Frecuencia: ${reminder.frequency}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            if (reminder.intervalHours != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 18, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    "Cada ${reminder.intervalHours} horas",
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),

            // Fecha inicio
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Colors.black54,
                ),
                const SizedBox(width: 6),
                Text(
                  "Inicio: ${_formatDate(reminder.startTime)}",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Mensaje
            Text(
              reminder.message,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 12),

            // Estado
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: reminder.isActive
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  reminder.isActive ? "ACTIVO" : "INACTIVO",
                  style: TextStyle(
                    color: reminder.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
