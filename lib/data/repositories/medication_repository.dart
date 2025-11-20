import '../datasources/medication_remote_datasource.dart';
import '../models/medication.dart';
import '../models/drug.dart';

class MedicationRepository {
  final MedicationRemoteDataSource remote;

  MedicationRepository(this.remote);

  Future<List<Medication>> getPatientMedications(int patientId) {
    return remote.fetchPatientMedications(patientId);
  }

  Future<List<Drug>> getDrugsCatalog() {
    return remote.fetchDrugsWithVariants();
  }

  Future<Medication> createMedication(Map<String, dynamic> payload) {
    return remote.createMedication(payload);
  }

  Future<void> deleteMedication(int id) {
    return remote.deleteMedication(id);
  }
}
