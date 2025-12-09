import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/shared_access_provider.dart';
import '../../providers/auth_provider.dart';

class DoctorPatientsScreen extends ConsumerWidget {
  const DoctorPatientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedAccessState = ref.watch(sharedAccessNotifierProvider);
    final auth = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text(
          "Mis Pacientes",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
      ),
      body: sharedAccessState.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (err, _) => Center(child: Text("Error: $err")),

        data: (list) {
          if (auth == null) {
            return const Center(child: Text("No autenticado"));
          }

          final patients = list
              .where(
                (sa) =>
                    sa.role == "doctor" &&
                    sa.owner.id != auth.id &&
                    sa.status == "accepted",
              )
              .toList();

          if (patients.isEmpty) {
            return const Center(
              child: Text(
                "No tienes pacientes asignados",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: patients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final sa = patients[i];
              final patient = sa.owner;

              return Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    context.pushNamed(
                      'patient_detail',
                      pathParameters: {'id': patient.id.toString()},
                      extra: patient,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(
                            0xFF1565C0,
                          ).withOpacity(.15),
                          child: const Icon(
                            Icons.person,
                            size: 32,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${patient.firstName} ${patient.lastName}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                patient.email,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: Colors.black45,
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
    );
  }
}
