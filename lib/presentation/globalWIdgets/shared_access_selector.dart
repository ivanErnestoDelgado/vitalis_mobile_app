import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/shared_access_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/shared_access.dart';
import '../../data/models/auth_response.dart';
import '../../data/models/user_profile.dart';

class SharedAccessSelector extends ConsumerWidget {
  final int? selectedId;
  final void Function(int userProfileId) onSelected;
  final String mode; // "doctor" o "patient"

  const SharedAccessSelector({
    super.key,
    required this.selectedId,
    required this.onSelected,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedAccessAsync = ref.watch(sharedAccessNotifierProvider);
    final auth = ref.watch(authStateProvider).value;

    return sharedAccessAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => const Center(child: Text("Error al cargar accesos")),
      data: (items) {
        if (auth == null) {
          return const Center(child: Text("No autenticado"));
        }

        // --- FILTRO ---
        final filtered = items.where((sa) {
          final isOwner = sa.owner.id == auth.id;

          if (mode == "doctor") {
            return sa.role == "doctor" && !isOwner;
          }

          if (mode == "patient") {
            if (sa.role == "doctor" && !isOwner) return false;
            return true;
          }

          return false;
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text("No hay conexiones disponibles"));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mode == "doctor"
                  ? "Selecciona un paciente"
                  : "Selecciona una persona",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 12),

            ...filtered.map(
              (sa) => _SharedAccessItem(
                sa: sa,
                auth: auth,
                selectedId: selectedId,
                onSelected: onSelected,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SharedAccessItem extends StatelessWidget {
  final SharedAccess sa;
  final AuthResponse auth;
  final int? selectedId;
  final void Function(int userProfileId) onSelected;

  const _SharedAccessItem({
    required this.sa,
    required this.auth,
    required this.selectedId,
    required this.onSelected,
  });

  String _initials(UserProfile p) =>
      "${p.firstName.isNotEmpty ? p.firstName[0] : ''}"
              "${p.lastName.isNotEmpty ? p.lastName[0] : ''}"
          .toUpperCase();

  @override
  Widget build(BuildContext context) {
    final UserProfile person = auth.id != sa.sharedWith.id
        ? sa.sharedWith
        : sa.owner;

    final bool isSelected = selectedId == person.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => onSelected(person.id),
        contentPadding: const EdgeInsets.all(16),

        leading: CircleAvatar(
          backgroundColor: const Color(0xFFBBDEFB),
          child: Text(
            _initials(person),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
        ),

        title: Text(
          "${person.firstName} ${person.lastName}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: Text(person.email),

        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF2196F3), size: 28)
            : const Icon(Icons.radio_button_unchecked),
      ),
    );
  }
}
