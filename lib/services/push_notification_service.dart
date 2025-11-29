import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  static Future<void> initialize() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Solicitar permisos en iOS
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    ///APP EN PRIMER PLANO
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("📲 Notificación en FOREGROUND");
      log("Título: ${message.notification?.title}");
      log("Cuerpo:  ${message.notification?.body}");
      log("Data:   ${message.data}");
    });

    ///APP EN SEGUNDO PLANO Y USUARIO LA TOCA
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("Notificación CLICKED mientras estaba en segundo plano");
      log("Data: ${message.data}");
    });

    ///APP CERRADA POR COMPLETO
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null) {
      log("La app fue ABIERTA desde una notificación");
      log("Data: ${initialMessage.data}");
      // Aqui también puedes navegar
    }
  }
}
