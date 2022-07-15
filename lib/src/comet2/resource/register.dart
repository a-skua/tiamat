/// COMET2's register
class Register {
  final String name;
  final int bits;

  int _value = 0;

  /// Construct
  ///
  /// [bits] is greater than 0.
  Register(
    this.name, {
    this.bits = 16,
  });

  /// Get mask bits.
  int get maskBits => (-1).toUnsigned(bits);

  /// Get [value].
  int get value => _value;

  /// Get [signed] value.
  int get signed => _value.toSigned(bits);

  /// Set [value].
  set value(int value) => _value = value & maskBits;
}
