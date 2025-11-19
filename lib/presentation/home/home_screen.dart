import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../globalWIdgets/role_options_panel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int currentIndex = 0;

  late List<String> activeRoles;
  late List<BottomNavigationBarItem> navItems;

  final Map<String, List<String>> roleMenus = {
    "patient": ["Medicaciones", "Compartir acceso", "Recordatorios"],
    "doctor": [
      "Accesos compartidos",
      "Consulta de medicamentos",
      "Recordatorios",
      "Pacientes",
    ],
    "family": ["Recordatorios", "Familiares Registrados"],
  };

  @override
  void initState() {
    super.initState();
    navItems = [];
    activeRoles = [];
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

    navItems = [];
    activeRoles = [];

    for (final role in user.roles) {
      if (roleMenus.containsKey(role)) {
        String label = adaptRoleNameToLabel(role);
        activeRoles.add(role);

        navItems.add(
          BottomNavigationBarItem(
            icon: Icon(_getRoleIcon(role)),
            label: _capitalize(label),
          ),
        );
      }
    }

    final currentRole = activeRoles[currentIndex];
    final options = roleMenus[currentRole]!;

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

      /// El menú dinámico:
      body: RoleOptionsPanel(
        options: options,
        onSelected: (option) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Clicked: $option")));
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        items: navItems,
        onTap: (i) => setState(() => currentIndex = i),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case "patient":
        return Icons.person;
      case "doctor":
        return Icons.medical_services;
      case "family":
        return Icons.family_restroom;
      default:
        return Icons.circle;
    }
  }

  String _capitalize(String role) =>
      "${role[0].toUpperCase()}${role.substring(1)}";

  String adaptRoleNameToLabel(String role) {
    switch (role) {
      case "patient":
        return "Paciente";
      case "doctor":
        return "Doctor";
      case "family":
        return "Familiares";
      default:
        return "Nada";
    }
  }
}
