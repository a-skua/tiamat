/// COMET2's memory
///
/// ```
/// final memory = Memory();
/// memory[0] = 0x8100;
/// ```
class Memory {
  List<int> _values = [];
  int _maskBits = 0;

  /// New COMET2's memory instance.
  ///
  /// [length] specifies the length of memory,
  /// and [wordLength] specifies the length of word.
  /// Memory size: [length] x [wordLength].
  Memory({
    int length = 0x10000,
    int wordLength = 16,
  }) {
    this._values = List.filled(length, 0);
    this._maskBits = (-1).toUnsigned(wordLength);
  }

  /// Memory length.
  int get length => this._values.length;

  /// Set [values] on memory.
  void setAll(final int address, final List<int> values) =>
      this._values.setAll(address, values);

  /// Get value from [address].
  int operator [](final int address) =>
      this._values[address % this._values.length];

  /// Set [value] to [address].
  void operator []=(final int address, final int value) =>
      this._values[address % this._values.length] = value & this._maskBits;

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
