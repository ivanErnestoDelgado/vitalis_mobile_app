import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reminder_access_provider.dart';
import '../../providers/reminders_provider.dart';

Color get vitalisBlue => const Color(0xFF0A84FF);
Color get vitalisBlueDark => const Color(0xFF0066CC);

class ReminderAccessListScreen extends ConsumerWidget {
  const ReminderAccessListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessListAsync = ref.watch(reminderAccessNotifierProvider);
    final remindersAsync = ref.watch(remindersNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Accesos a recordatorios",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: vitalisBlue,
        elevation: 0,
      ),
      body: accessListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (accessList) {
          if (accessList.isEmpty) {
            return const Center(
              child: Text(
                "Sin accesos registrados",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return remindersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(child: Text("Error: $err")),
            data: (reminders) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: accessList.length,
                itemBuilder: (_, i) {
                  final access = accessList[i];

                  // Buscar el reminder asociado
                  final reminder = reminders.firstWhere(
                    (r) => r.id == access.reminder,
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {}, // puedes abrir pantalla de detalle aquí
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre del usuario
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.lightBlue,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "${access.userInfo.firstName} ${access.userInfo.lastName}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(
                                          reminderAccessNotifierProvider
                                              .notifier,
                                        )
                                        .delete(access.id);
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Email
                            Text(
                              access.userInfo.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 16),
                            const Divider(height: 1),

                            // Datos del reminder
                            ...[
                              const SizedBox(height: 16),
                              Text(
                                reminder.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: vitalisBlueDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                reminder.message,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 18,
                                    color: Colors.black45,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${reminder.frequency} — ${reminder.startTime}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              if (reminder.intervalHours != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.repeat,
                                        size: 18,
                                        color: Colors.black45,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Cada ${reminder.intervalHours} horas",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],

                            const SizedBox(height: 12),
                            /*
                            const Divider(height: 1),

                            // Permisos
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              children: [
                                _chip("Editar", access.canEdit, Icons.edit),
                                _chip(
                                  "Eliminar",
                                  access.canDelete,
                                  Icons.delete_forever,
                                ),
                                _chip(
                                  "Notif.",
                                  access.receiveNotifications,
                                  Icons.notifications,
                                ),
                              ],
                            ),
                            */
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _chip(String text, bool active, IconData icon) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: active ? Colors.white : Colors.grey.shade400,
      ),
      label: Text(
        text,
        style: TextStyle(color: active ? Colors.white : Colors.grey.shade400),
      ),
      backgroundColor: active ? vitalisBlue : Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
