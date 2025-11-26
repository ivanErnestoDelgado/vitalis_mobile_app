import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/shared_access_provider.dart';

class GenerateQrScreen extends ConsumerStatefulWidget {
  final String role;
  const GenerateQrScreen({super.key, required this.role});

  @override
  ConsumerState<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends ConsumerState<GenerateQrScreen> {
  String? token;
  DateTime? expires;
  bool loading = false;

  Future<void> _generate() async {
    setState(() => loading = true);
    try {
      final resp = await ref
          .read(sharedAccessNotifierProvider.notifier)
          .generateQR();
      token = resp.token;
      expires = resp.expiresAt;
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generando QR: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  'Generar QR',
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
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            if (token != null) ...[
              AnimatedScale(
                scale: 1,
                duration: const Duration(milliseconds: 300),
                child: QrImageView(data: token!, size: 240),
              ),
              const SizedBox(height: 14),
              Text(
                'Token: $token',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Text(
                'Expira: ${expires?.toLocal().toString() ?? ''}',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 22),
            ],
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C6CF2),
                elevation: 4,
                shadowColor: const Color(0xFF0C6CF2).withOpacity(0.4),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: loading ? null : _generate,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      token == null ? 'Generar QR' : 'Regenerar QR',
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
