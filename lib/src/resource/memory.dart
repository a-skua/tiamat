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
  /// and [maskBits] specifies the data size.
  Memory({
    int length = 0x10000,
    int maskBits = 0xffff,
  }) {
    this._values = List.filled(length, 0);
    this._maskBits = maskBits;
  }

  /// Memory length.
  int get length => this._values.length;

  /// Set [values] on memory.
  void setAll(int address, List<int> values) =>
      this._values.setAll(address, values);

  /// Get value from [address].
  int operator [](int address) => this._values[address % this._values.length];

  /// Set [value] to [address].
  void operator []=(final int address, final int value) =>
      this._values[address % this._values.length] = value & this._maskBits;
}
