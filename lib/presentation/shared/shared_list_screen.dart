import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/shared_access_provider.dart';
import '../../providers/auth_provider.dart';

class SharedAccessListScreen extends ConsumerWidget {
  final String role; // "patient" o "doctor"
  const SharedAccessListScreen({super.key, required this.role});

  Color _statusColor(String s) {
    return switch (s) {
      "accepted" => Colors.green,
      "pending" => Colors.orange,
      "rejected" => Colors.red,
      _ => Colors.grey,
    };
  }

  IconData _roleIcon(String role) {
    return switch (role) {
      "doctor" => Icons.local_hospital_outlined,
      "family" => Icons.family_restroom,
      _ => Icons.person_outline,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sharedAccessNotifierProvider);
    final auth = ref.watch(authStateProvider).value;

    return state.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),

      data: (list) {
        final filtered = list.where((s) {
          final isOwner = auth != null && auth.id == s.owner.id;

          if (role == "patient") {
            // EXCLUIR si es doctor Y NO es owner
            if (s.role == "doctor" && !isOwner) return false;
            return true;
          }

          if (role == "doctor") {
            // SOLO mostrar doctor y NO owner
            if (s.role == "doctor" && !isOwner) return true;
            return false;
          }

          return true;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF3F7FB),

          appBar: AppBar(
            backgroundColor: const Color(0xFF0C6CF2),
            elevation: 0,
            title: const Text(
              "Accesos compartidos",
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/home'),
            ),
          ),

          body: filtered.isEmpty
              ? const Center(
                  child: Text(
                    "No hay accesos para mostrar",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),

                  itemBuilder: (_, i) {
                    final s = filtered[i];
                    final isOwner = auth != null && auth.id == s.owner.id;
                    final otherUser = isOwner ? s.sharedWith : s.owner;

                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.93, end: 1),
                      duration: const Duration(milliseconds: 240),

                      builder: (_, scale, child) =>
                          Transform.scale(scale: scale, child: child),

                      child: InkWell(
                        onTap: () => context.push('/shared/detail', extra: s),
                        borderRadius: BorderRadius.circular(18),

                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),

                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFEAF1FF),
                                ),
                                child: Icon(
                                  _roleIcon(s.role),
                                  color: const Color(0xFF0C6CF2),
                                  size: 28,
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${otherUser.firstName} ${otherUser.lastName}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      otherUser.email,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    Text(
                                      "Rol: ${s.role}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF1A2E46),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor(
                                    s.status,
                                  ).withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  s.status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _statusColor(s.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
