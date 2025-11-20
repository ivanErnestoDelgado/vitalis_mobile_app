class DateValidators {
  static String? validateDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return "Las fechas son obligatorias.";
    }

    if (end.isBefore(start)) {
      return "La fecha final no puede ser anterior a la inicial.";
    }

    return null;
  }
}
