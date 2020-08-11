abstract class SignUpStep {
  Map _errors;

  void setInitialErrorValues(Map keyValues) {
    _errors = keyValues;
  }

  Map get errors => _errors;

  void setError(Map keyValue) {
    // updateAll() ?
    keyValue.forEach((key, value) {
      _errors[key] = value;
    });
  }

  bool isValid() => _errors.entries.every(
        (MapEntry entry) {
          return entry.value.isEmpty;
        },
      );
}
