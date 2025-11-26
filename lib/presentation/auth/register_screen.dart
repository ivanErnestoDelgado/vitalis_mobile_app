import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/register_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final emailCtrl = TextEditingController();
  final firstCtrl = TextEditingController();
  final lastCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool showPassword = false;

  late AnimationController anim;
  late Animation<double> fade;
  late Animation<Offset> slide;

  @override
  void initState() {
    super.initState();
    anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);

    slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack));

    anim.forward();
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    firstCtrl.dispose();
    lastCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F7FF),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(30),
          child: FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: slide,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 35,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Vitalis",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A3C78),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.health_and_safety_rounded,
                        size: 55,
                        color: Color(0xFF0A3C78),
                      ),
                    ),

                    const SizedBox(height: 30),

                    _field(emailCtrl, "Email", Icons.email),
                    const SizedBox(height: 12),

                    _field(firstCtrl, "Nombre", Icons.person),
                    const SizedBox(height: 12),

                    _field(lastCtrl, "Apellido", Icons.badge),
                    const SizedBox(height: 12),

                    _field(phoneCtrl, "Teléfono", Icons.phone),
                    const SizedBox(height: 12),

                    _passwordField(),

                    const SizedBox(height: 25),

                    state.isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A74DA),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () async {
                              await ref
                                  .read(registerControllerProvider.notifier)
                                  .register(
                                    email: emailCtrl.text.trim(),
                                    firstName: firstCtrl.text.trim(),
                                    lastName: lastCtrl.text.trim(),
                                    phone: phoneCtrl.text.trim(),
                                    password: passCtrl.text.trim(),
                                  );

                              if (mounted && !state.hasError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Registro exitoso. Ahora inicia sesión.",
                                    ),
                                  ),
                                );
                                context.go('/login');
                              }
                            },
                            child: const Text(
                              "Registrarme",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),

                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          "Error: ${state.error}",
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 25),

                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        "¿Ya tienes cuenta? Iniciar sesión",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF0A3C78),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue.shade700),
        labelText: label,
        filled: true,
        fillColor: Colors.blue.shade50,
        focusedBorder: _border(),
        enabledBorder: _border(),
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: passCtrl,
      obscureText: !showPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.blue.shade700,
          ),
          onPressed: () => setState(() => showPassword = !showPassword),
        ),
        labelText: "Contraseña",
        filled: true,
        fillColor: Colors.blue.shade50,
        focusedBorder: _border(),
        enabledBorder: _border(),
      ),
    );
  }

  OutlineInputBorder _border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.blue.shade200),
    );
  }
}
