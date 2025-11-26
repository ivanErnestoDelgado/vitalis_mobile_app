import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/medication_provider.dart';
import 'package:go_router/go_router.dart';

class ViewDrugCatalogScreen extends ConsumerWidget {
  const ViewDrugCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drugsAsync = ref.watch(drugCatalogProvider);

    return drugsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, st) => Scaffold(body: Center(child: Text("Error: $err"))),
      data: (drugs) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F9FA),
          appBar: AppBar(
            title: const Text("Catálogo de Medicamentos"),
            backgroundColor: const Color(0xFF0A8EA0),
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => context.go('/home'), // ← AQUÍ
              ),
            ],
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: drugs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final d = drugs[i];

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ExpansionTile(
                  title: Text(
                    d.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Text(d.description),
                  childrenPadding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 12,
                  ),
                  children: d.variants.isEmpty
                      ? [const ListTile(title: Text("No hay variantes"))]
                      : [
                          ...d.variants.map(
                            (v) => ListTile(
                              title: Text(
                                v.variantName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text("${v.dosage} • ${v.manufacturer}"),
                              trailing: Chip(
                                label: Text(
                                  v.available ? "Disponible" : "No disponible",
                                ),
                                backgroundColor: v.available
                                    ? Colors.green[100]
                                    : Colors.red[100],
                              ),
                            ),
                          ),
                        ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
