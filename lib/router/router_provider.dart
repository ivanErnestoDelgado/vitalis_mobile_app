import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../presentation/login/login_screen.dart';
import '../presentation/home/home_screen.dart';
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

      if (!loggedIn && !isLoginPage) {
        return '/login';
      }
      if (loggedIn && isLoginPage) {
        return '/home';
      }
      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    ],
  );
});
