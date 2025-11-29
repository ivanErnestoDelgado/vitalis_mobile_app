import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalis_mobile_app/firebase_messaging_handler.dart';
import 'package:vitalis_mobile_app/services/push_notification_service.dart';
import 'router/router_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await PushNotificationService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(firebaseInitProvider);

    return init.when(
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => MaterialApp(
        home: Scaffold(body: Center(child: Text("Error: $e"))),
      ),
      data: (_) {
        final router = ref.watch(routerProvider);
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        );
      },
    );
  }
}

final firebaseInitProvider = FutureProvider<void>((ref) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  return;
});
