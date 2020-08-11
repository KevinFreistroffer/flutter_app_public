abstract class FormControl {
  dynamic _value;
  dynamic _error;

  dynamic get error => _error;
  dynamic get value => _value;

  void setError(value) => _error = value;
  void setValue(value) => _value = value;

  bool isValid() => _error == null;
}
