import 'dart:async';
import 'package:flutter/foundation.dart';

class StreamToListenable extends ChangeNotifier {
  late final StreamSubscription _sub;

  StreamToListenable(Stream stream) {
    _sub = stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
