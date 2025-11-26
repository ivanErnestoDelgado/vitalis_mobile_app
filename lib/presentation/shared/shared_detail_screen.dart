import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/user_profile.dart';
import '../../data/models/shared_access.dart';
import '../../providers/shared_access_provider.dart';
import '../../providers/auth_provider.dart';

class SharedAccessDetailScreen extends ConsumerWidget {
  final SharedAccess shared;
  const SharedAccessDetailScreen({super.key, required this.shared});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider).value;

    final isOwner = auth != null && auth.id == shared.owner.id;
    final isReceiver = auth != null && auth.id == shared.sharedWith.id;

    final canAccept = shared.status == "pending" && isReceiver;
    final canReject = shared.status == "pending" && isReceiver;
    final canRevoke = isOwner;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FE),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0C6CF2),
        title: const Text(
          "Detalle del acceso",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/shared/list'),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Información general"),
            _infoRow(
              Icons.medical_services_outlined,
              "Rol asignado",
              shared.role,
            ),
            _infoRow(Icons.verified_user, "Estado", shared.status),
            _infoRow(
              Icons.calendar_today,
              "Creado el",
              "${shared.createdAt.day}/${shared.createdAt.month}/${shared.createdAt.year}",
            ),

            const SizedBox(height: 22),
            _sectionTitle("Propietario del acceso"),
            _userCard(shared.owner),

            const SizedBox(height: 22),
            _sectionTitle("Acceso compartido con"),
            _userCard(shared.sharedWith),

            const SizedBox(height: 22),

            if (canAccept)
              _actionBtn("Aceptar invitación", Colors.green, () async {
                await _handle(context, ref, () async {
                  await ref
                      .read(sharedAccessNotifierProvider.notifier)
                      .accept(shared.id);
                });
              }),

            if (canReject)
              _actionBtn("Rechazar invitación", Colors.red, () async {
                await _handle(context, ref, () async {
                  await ref
                      .read(sharedAccessNotifierProvider.notifier)
                      .reject(shared.id);
                });
              }),

            if (canRevoke)
              _actionBtn("Revocar acceso", Colors.orange, () async {
                await _handle(context, ref, () async {
                  await ref
                      .read(sharedAccessNotifierProvider.notifier)
                      .revoke(shared.id);
                });
              }),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // COMPONENTES DE UI
  // ---------------------------------------------------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A2E46),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF0C6CF2), size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _userCard(UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${user.firstName} ${user.lastName}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _infoRow(Icons.email_outlined, "Email", user.email),
          _infoRow(Icons.phone, "Teléfono", user.phoneNumber),
          _infoRow(
            Icons.calendar_today,
            "Registrado el",
            "${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}",
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String text, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 17),
        ),
      ),
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() fn,
  ) async {
    try {
      await fn();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Operación realizada")));
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
