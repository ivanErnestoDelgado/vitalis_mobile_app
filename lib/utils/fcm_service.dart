import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
}
