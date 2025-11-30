import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../globalWIdgets/role_options_panel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;

  late List<String> activeRoles;
  late List<BottomNavigationBarItem> navItems;

  AnimationController? _animController;
  Animation<double>? _fadeAnim;
  Animation<Offset>? _slideAnim;

  final Map<String, List<String>> roleMenus = {
    "patient": [
      "Consulta de medicamentos",
      "Medicaciones",
      "Compartir acceso",
      "Recordatorios",
    ],
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

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController!, curve: Curves.easeOut));

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, .05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController!, curve: Curves.easeOut));

    _animController!.forward();
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        activeRoles.add(role);

        navItems.add(
          BottomNavigationBarItem(
            icon: Icon(_getRoleIcon(role)),
            label: _capitalize(adaptRoleNameToLabel(role)),
          ),
        );
      }
    }

    final currentRole = activeRoles[currentIndex];
    final options = roleMenus[currentRole]!;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: const Color(0xFF0C6CF2),
        title: Text(
          "Bienvenido a Vitalis ${user.firstName}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 195, 205, 212),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
            color: Color.fromARGB(255, 195, 205, 212),
          ),
        ],
      ),

      body: FadeTransition(
        opacity: _fadeAnim!,
        child: SlideTransition(
          position: _slideAnim!,
          child: RoleOptionsPanel(options: options, onSelected: _handleOption),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF0C6CF2),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        onTap: (i) => setState(() => currentIndex = i),
        items: navItems,
      ),
    );
  }

  void _handleOption(String option) {
    switch (option) {
      /// Paciente
      case "Medicaciones":
        context.push('/medications');
        break;

      case "Consulta de medicamentos":
        context.push('/medications/catalog');
        break;

      case "Compartir acceso":
        context.push('/shared?role=patient');
        break;

      /// Doctor
      case "Accesos compartidos":
        context.push('/shared?role=doctor');
        break;

      case "Recordatorios":
        context.push('/reminders');
        break;

      /// Family – en caso de que agregues algo después
      case "Familiares Registrados":
        // Aquí después puedes meter otra ruta.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pantalla no implementada")),
        );
        break;

      /// Default
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Clicked: $option")));
    }
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

  String _capitalize(String s) => "${s[0].toUpperCase()}${s.substring(1)}";

  String adaptRoleNameToLabel(String role) {
    switch (role) {
      case "patient":
        return "Paciente";
      case "doctor":
        return "Doctor";
      case "family":
        return "Familiares";
      default:
        return "Otro";
    }
  }
}
