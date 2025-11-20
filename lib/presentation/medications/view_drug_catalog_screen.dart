import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/medication_provider.dart';

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
          appBar: AppBar(title: const Text("Catálogo de Medicamentos")),
          body: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: drugs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final d = drugs[i];
              return Card(
                child: ExpansionTile(
                  title: Text(d.name),
                  subtitle: Text(d.description),
                  children: [
                    if (d.variants.isEmpty)
                      const ListTile(title: Text("No hay variantes")),
                    ...d.variants.map(
                      (v) => ListTile(
                        title: Text(v.variantName),
                        subtitle: Text("${v.dosage} • ${v.manufacturer}"),
                        trailing: v.available
                            ? const Text("Disponible")
                            : const Text("No disponible"),
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
