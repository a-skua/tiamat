/// COMET2's register
class Register {
  final String name;
  final int bits;

  int _value = 0;

  Register(
    this.name, {
    this.bits = 16,
  }) {
    assert(bits > 0, 'bits must be greater than zero!');
  }

  /// Get mask bits.
  int get maskBits => (-1).toUnsigned(this.bits);

  /// Get [value].
  int get value => this._value;

  /// Get [signed] value.
  int get signed => this._value.toSigned(this.bits);

  /// Set [value].
  void set value(int value) => this._value = value & this.maskBits;
}
