import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/shared_access_provider.dart';

class ScanQrScreen extends ConsumerStatefulWidget {
  final String role;
  const ScanQrScreen({super.key, required this.role});

  @override
  ConsumerState<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends ConsumerState<ScanQrScreen> {
  bool processing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (processing) return;

    final barcode = capture.barcodes.firstOrNull;
    final code = barcode?.rawValue;

    if (code == null) return;

    processing = true;

    try {
      await ref
          .read(sharedAccessNotifierProvider.notifier)
          .connectViaQR(code, widget.role);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acceso compartido creado con éxito')),
      );

      context.go('/shared/list');
    } catch (e) {
      processing = false;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error conectando vía QR: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0C6CF2),
      ),
      body: MobileScanner(fit: BoxFit.cover, onDetect: _onDetect),
    );
  }
}
