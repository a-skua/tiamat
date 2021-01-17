/// COMET2's register
class Register {
  final String name;
  int _value = 0;
  int _maskBits = 0;

  Register(
    this.name, {
    int value = 0,
    int bits = 16,
  }) {
    this._maskBits = (-1).toUnsigned(bits);
    this.value = value;
  }

  /// Get [value].
  int get value => this._value;

  /// Set [value].
  void set value(int value) => this._value = value & this._maskBits;
}
