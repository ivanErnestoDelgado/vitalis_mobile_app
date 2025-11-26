import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/shared_access_provider.dart';
import '../../providers/auth_provider.dart';

class SharedAccessListScreen extends ConsumerWidget {
  const SharedAccessListScreen({super.key});

  Color _statusColor(String s) {
    switch (s) {
      case "accepted":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _roleIcon(String role) {
    if (role == "doctor") return Icons.medical_services_outlined;
    return Icons.family_restroom;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sharedAccessNotifierProvider);
    final auth = ref.watch(authStateProvider).value;

    return state.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (list) => Scaffold(
        backgroundColor: const Color(0xFFF3F7FB),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0C6CF2),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Accesos compartidos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(18),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, i) {
            final s = list[i];
            final amIOwner = auth != null && auth.id == s.owner;

            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.92, end: 1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  context.push('/shared/detail', extra: s);
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
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
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0C6CF2).withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          _roleIcon(s.role),
                          size: 28,
                          color: const Color(0xFF0C6CF2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${s.role.toUpperCase()} • ID ${s.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Color(0xFF1A2E46),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              amIOwner
                                  ? 'Tú eres el dueño de este acceso'
                                  : 'Compartido contigo',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
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
                          color: _statusColor(s.status).withOpacity(0.15),
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
      ),
    );
  }
}
