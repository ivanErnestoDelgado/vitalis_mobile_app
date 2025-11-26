import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/shared_access.dart';
import '../../providers/shared_access_provider.dart';
import '../../providers/auth_provider.dart';

class SharedAccessDetailScreen extends ConsumerWidget {
  final SharedAccess shared;
  const SharedAccessDetailScreen({super.key, required this.shared});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider).value;
    final amIOwner = auth != null && auth.id == shared.owner;
    final amIReceiver = auth != null && auth.id == shared.sharedWith;

    final canAccept = shared.status == 'pending' && amIReceiver;
    final canReject = shared.status == 'pending' && amIReceiver;
    final canRevoke = amIOwner; // owner can revoke (pending or accepted)

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: Text(
          'Acceso #${shared.id}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0C6CF2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rol: ${shared.role}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Estado: ${shared.status}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (canAccept)
              _actionBtn(context, 'Aceptar invitación', Colors.green, () async {
                try {
                  await ref
                      .read(sharedAccessNotifierProvider.notifier)
                      .accept(shared.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invitación aceptada')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }),
            if (canReject)
              _actionBtn(context, 'Rechazar invitación', Colors.red, () async {
                try {
                  await ref
                      .read(sharedAccessNotifierProvider.notifier)
                      .reject(shared.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invitación rechazada')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }),
            if (canRevoke)
              _actionBtn(
                context,
                'Revocar invitación',
                Colors.orange,
                () async {
                  try {
                    await ref
                        .read(sharedAccessNotifierProvider.notifier)
                        .revoke(shared.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invitación revocada')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(
    BuildContext context,
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 50),
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
}
