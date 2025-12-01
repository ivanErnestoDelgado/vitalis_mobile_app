import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reminders_provider.dart';
import '../../data/models/reminder.dart';
import 'package:go_router/go_router.dart';

class RemindersListScreen extends ConsumerWidget {
  const RemindersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      //APPBAR PERSONALIZADA CON BOTÓN DE REGRESO
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade400],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // ← BOTÓN DE REGRESAR
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  onPressed: () => context.pop(),
                ),

                const Expanded(
                  child: Center(
                    child: Text(
                      "Mis Recordatorios",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                //SizedBox(width: 48), // Para equilibrio visual
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () => context.push('/reminders/access'),
                ),
                SizedBox(width: 20),
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade600,
        onPressed: () => context.push('/reminders/create'),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return reminders.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Error: $e")),
            data: (items) {
              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    "No tienes recordatorios",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (_, i) => _ReminderCard(
                  reminder: items[i],
                  maxWidth: constraints.maxWidth,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final double maxWidth;

  const _ReminderCard({required this.reminder, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => context.push('/reminders/${reminder.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.alarm,
                      color: Colors.blue.shade700,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: maxWidth < 350 ? 16 : 18,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reminder.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: maxWidth < 350 ? 13 : 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: Colors.blue.shade400,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Frecuencia: ${reminder.frequency}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.blue.shade400,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Inicio: ${reminder.startTime}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 🔵 BOTÓN DE ACCESO
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    context.push('/reminders/${reminder.id}/access');
                  },
                  icon: const Icon(Icons.share),
                  label: const Text("Dar acceso"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
