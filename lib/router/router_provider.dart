import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vitalis_mobile_app/presentation/auth/register_screen.dart';
import 'package:vitalis_mobile_app/presentation/reminders/create_reminder_access_screen.dart';
import 'package:vitalis_mobile_app/presentation/reminders/create_reminder_screen.dart';
import 'package:vitalis_mobile_app/presentation/reminders/reminder_access_list_screen.dart';
import 'package:vitalis_mobile_app/presentation/reminders/reminder_detail_screen.dart';
import 'package:vitalis_mobile_app/presentation/reminders/reminder_edit_screen.dart';
import 'package:vitalis_mobile_app/presentation/reminders/reminder_list_screen.dart';

import '../data/models/shared_access.dart';

import '../providers/auth_provider.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/medications/patient_medications_screen.dart';
import '../presentation/medications/create_medication_screen.dart';
import '../presentation/medications/view_drug_catalog_screen.dart';

import 'package:vitalis_mobile_app/presentation/shared/shared_home_screen.dart';
import 'package:vitalis_mobile_app/presentation/shared/invite_by_email_screen.dart';
import 'package:vitalis_mobile_app/presentation/shared/generate_qr_screen.dart';
import 'package:vitalis_mobile_app/presentation/shared/scan_qr_screen.dart';
import 'package:vitalis_mobile_app/presentation/shared/shared_list_screen.dart';
import 'package:vitalis_mobile_app/presentation/shared/shared_detail_screen.dart';

import 'stream_listenable.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authStream = ref.watch(authStateProvider.notifier).stream;

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: StreamToListenable(authStream),

    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      final loggedIn = authState.value != null;
      final isLoginPage = state.matchedLocation == '/login';
      final isRegisterPage = state.matchedLocation == '/register';

      if (!loggedIn && !isLoginPage && !isRegisterPage) {
        return '/login';
      }
      if (loggedIn && isLoginPage) {
        return '/home';
      }
      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(
        path: '/medications',
        builder: (_, __) => const PatientMedicationsScreen(),
      ),
      GoRoute(
        path: '/medications/create',
        builder: (_, __) => const CreateMedicationScreen(),
      ),
      GoRoute(
        path: '/medications/catalog',
        builder: (_, __) => const ViewDrugCatalogScreen(),
      ),
      GoRoute(
        path: '/shared',
        builder: (_, state) {
          final role = state.uri.queryParameters['role'] ?? 'patient';
          return SharedAccessHomeScreen(role: role);
        },
      ),
      GoRoute(
        path: '/shared/invite',
        builder: (_, state) {
          return InviteByEmailScreen();
        },
      ),
      GoRoute(
        path: '/shared/qr',
        builder: (_, state) {
          final role = state.uri.queryParameters['role'] ?? 'patient';
          return GenerateQrScreen(role: role);
        },
      ),
      GoRoute(
        path: '/shared/scan',
        builder: (_, state) {
          final role = state.uri.queryParameters['role'] ?? 'patient';
          return ScanQrScreen(role: role);
        },
      ),
      GoRoute(
        path: '/shared/list',
        builder: (_, state) {
          final role = state.uri.queryParameters['role'] ?? 'patient';
          return SharedAccessListScreen(role: role);
        },
      ),
      GoRoute(
        path: '/shared/detail',
        builder: (_, state) {
          final shared = state.extra as SharedAccess;
          return SharedAccessDetailScreen(shared: shared);
        },
      ),
      GoRoute(
        path: '/reminders',
        name: 'reminders',
        builder: (context, state) => const RemindersListScreen(),
      ),
      GoRoute(
        path: '/reminders/access',
        builder: (_, __) => const ReminderAccessListScreen(),
      ),
      GoRoute(
        path: '/reminders/create',
        name: 'reminder_create',
        builder: (context, state) => const ReminderCreateScreen(),
      ),
      GoRoute(
        path: '/reminders/:id',
        name: 'reminder_detail',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ReminderDetailScreen(reminderId: id);
        },
      ),
      GoRoute(
        path: '/reminders/:id/edit',
        name: 'reminder_edit',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ReminderEditScreen(reminderId: id);
        },
      ),

      GoRoute(
        path: '/reminders/:id/access',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CreateReminderAccessScreen(reminderId: id);
        },
      ),
    ],
  );
});
