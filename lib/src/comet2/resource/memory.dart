/// COMET2's memory
///
/// ```
/// final memory = Memory();
/// memory[0] = 0x8100;
/// ```
class Memory {
  final int bits;

  List<int> _values = [];

  /// New COMET2's memory instance.
  ///
  /// [length] specifies the length of memory,
  /// and [bits] specifies the bits size of word.
  /// Memory size: [length] x [bits].
  Memory({
    int length = 0x10000,
    this.bits = 16,
  }) {
    _values = List.filled(length, 0);
  }

  /// Get mask bits.
  int get maskBits => (-1).toUnsigned(bits);

  /// Get memory [length].
  int get length => _values.length;

  /// Set [values] on memory.
  void setAll(final int address, final List<int> values) {
    for (var i = 0; i < values.length; i++) {
      this[address + i] = values[i];
    }
  }

  /// Get value from [address].
  int operator [](final int address) => _values[address % _values.length];

  /// Set [value] to [address].
  void operator []=(final int address, final int value) =>
      _values[address % _values.length] = value & maskBits;

  /// deprecated: To use operator.
  ///
  /// ```
  /// final m = Memory();
  /// print(m[adress]);
  /// ```
  @deprecated
  int getWord(final int address) => this[address];

  /// deprecated: To use operator.
  ///
  /// ```
  /// final m = Memory();
  /// m[adress] = value;
  /// ```
  @deprecated
  bool setWord(final int address, final int value) {
    this[address] = value;
    return true;
  }
}
