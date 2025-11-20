import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/medication_remote_datasource.dart';
import '../data/repositories/medication_repository.dart';
import '../data/models/medication.dart';
import '../data/models/drug.dart';
import 'auth_provider.dart';
import 'dart:async';

final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository(
    MedicationRemoteDataSource(
      token: ref.read(authStateProvider).value!.accessToken,
    ),
  );
});

/// Controller that holds the list and allows refresh/create/delete
class MedicationController extends StateNotifier<AsyncValue<List<Medication>>> {
  final Ref ref;
  final MedicationRepository repo;

  MedicationController(this.ref, this.repo)
    : super(const AsyncValue.loading()) {
    // fetch on create
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final auth = ref.read(authStateProvider).value;
      if (auth == null) {
        state = const AsyncValue.data([]);
        return;
      }
      final patientId = auth.id;
      final list = await repo.getPatientMedications(patientId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _fetch();

  Future<void> createMedication({
    required int patient,
    required int drugVariant,
    required String dosageInstructions,
    required String startDate,
    required String endDate,
  }) async {
    try {
      state = const AsyncValue.loading();
      final payload = {
        "patient": patient,
        "drug_variant": drugVariant,
        "dosage_instructions": dosageInstructions,
        "start_date": startDate,
        "end_date": endDate,
      };
      await repo.createMedication(payload);
      // optimistically refresh
      await _fetch();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteMedication(int id) async {
    try {
      state = const AsyncValue.loading();
      await repo.deleteMedication(id);
      await _fetch();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final medicationControllerProvider =
    StateNotifierProvider<MedicationController, AsyncValue<List<Medication>>>(
      (ref) =>
          MedicationController(ref, ref.read(medicationRepositoryProvider)),
    );

/// Provider para catálogo de medicamentos (lectura)
final drugCatalogProvider = FutureProvider<List<Drug>>((ref) async {
  final repo = ref.read(medicationRepositoryProvider);
  return repo.getDrugsCatalog();
});
