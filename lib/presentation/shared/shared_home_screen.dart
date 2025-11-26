import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SharedAccessHomeScreen extends StatelessWidget {
  final String role;
  const SharedAccessHomeScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C6CF2),
        title: const Text(
          "Compartir acceso",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _menuButton(
              context,
              icon: Icons.email_outlined,
              text: "Invitar por correo",
              onTap: () => context.push('/shared/invite?role=$role'),
            ),
            _menuButton(
              context,
              icon: Icons.qr_code_2,
              text: "Conectar mediante QR",
              onTap: () => context.push('/shared/qr?role=$role'),
            ),
            _menuButton(
              context,
              icon: Icons.group_outlined,
              text: "Ver accesos compartidos",
              onTap: () => context.push('/shared/list'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 34, color: const Color(0xFF0C6CF2)),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
