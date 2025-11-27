import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/medication_remote_datasource.dart';
import '../data/repositories/medication_repository.dart';
import '../data/models/medication.dart';
import '../data/models/drug.dart';
import 'auth_provider.dart';
import 'dart:async';

final medicationRepositoryProvider = Provider.autoDispose<MedicationRepository>(
  (ref) {
    final auth = ref.watch(authStateProvider).value;
    final token = auth?.accessToken ?? '';

    return MedicationRepository(MedicationRemoteDataSource(token: token));
  },
);

/// Controller that holds the list and allows refresh/create/delete
class MedicationController extends StateNotifier<AsyncValue<List<Medication>>> {
  final Ref ref;

  MedicationController(this.ref) : super(const AsyncValue.loading()) {
    _fetch();
  }

  MedicationRepository get repo => ref.watch(medicationRepositoryProvider);

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
    StateNotifierProvider.autoDispose<
      MedicationController,
      AsyncValue<List<Medication>>
    >((ref) => MedicationController(ref));

/// Provider para catálogo de medicamentos (lectura)
final drugCatalogProvider = FutureProvider.autoDispose<List<Drug>>((ref) async {
  final repo = ref.watch(medicationRepositoryProvider);
  return repo.getDrugsCatalog();
});
