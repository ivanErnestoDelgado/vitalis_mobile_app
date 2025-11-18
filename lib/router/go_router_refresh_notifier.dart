import 'dart:async';
import 'package:flutter/foundation.dart';

/// Envuelve cualquier clase que emita eventos (Stream),
/// permitiendo que GoRouter se refresque cuando cambian los estados.
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Stream<dynamic> stream) {
    notifyListeners(); // Notifica al crear

    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners(); // Se refresca cada vez que hay un cambio en el stream
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
