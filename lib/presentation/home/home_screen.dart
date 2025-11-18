import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int currentIndex = 0;

  late List<Widget> pages;
  late List<BottomNavigationBarItem> navItems;

  @override
  void initState() {
    super.initState();
    pages = [];
    navItems = [];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    if (user == null) {
      Future.microtask(() {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
      return const SizedBox.shrink();
    }

    // Limpiamos listas (por si rebuild)
    pages = [];
    navItems = [];

    if (user.roles.contains("patient")) {
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Paciente",
        ),
      );
      pages.add(const Center(child: Text("Pantalla Paciente")));
    }

    if (user.roles.contains("doctor")) {
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.medical_services),
          label: "Doctor",
        ),
      );
      pages.add(const Center(child: Text("Pantalla Doctor")));
    }

    if (user.roles.contains("family")) {
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.family_restroom),
          label: "Familiar",
        ),
      );
      pages.add(const Center(child: Text("Pantalla Familiar")));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenido, ${user.firstName}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        items: navItems,
        onTap: (i) => setState(() => currentIndex = i),
      ),
    );
  }
}
