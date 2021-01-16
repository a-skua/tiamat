const _len = 0x10000;
const _mask = 0xffff;

/// COMET2's memory
class Memory {
  final List<int> _values = List.filled(_len, 0);

  /// Memory length
  int get length => this._values.length;

  /// Get value from [address]
  int getWord(final int address) => this._values[address & _mask];

  /// Set [value] to [address]
  void setWord(final int address, final int value) =>
      this._values[address & _mask] = value & _mask;
}
