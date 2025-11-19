import 'package:flutter/material.dart';

class RoleOptionsPanel extends StatelessWidget {
  final List<String> options;
  final void Function(String option) onSelected;

  const RoleOptionsPanel({
    super.key,
    required this.options,
    required this.onSelected,
  });

  //Mapeo de iconos
  IconData _getIconForOption(String option) {
    final normalized = option.toLowerCase();
    if (normalized.contains("famili")) return Icons.family_restroom_rounded;
    if (normalized.contains("medic")) return Icons.medication;
    if (normalized.contains("compart")) return Icons.share;
    if (normalized.contains("record")) return Icons.access_alarm;
    if (normalized.contains("accesos")) return Icons.lock_open;
    if (normalized.contains("consulta")) return Icons.search;
    if (normalized.contains("paciente")) return Icons.people;

    return Icons.circle; // default icon
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (_, constraints) {
          final maxWidth = constraints.maxWidth;
          final crossAxisCount = maxWidth > 500 ? 2 : 1;

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 2.3,
            ),
            itemCount: options.length,
            itemBuilder: (_, i) {
              final label = options[i];
              final icon = _getIconForOption(label);

              return _OptionCard(
                label: label,
                icon: icon,
                onTap: () => onSelected(label),
              );
            },
          );
        },
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.blueAccent),
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
