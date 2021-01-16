import '../../resource/resource.dart';

/// Calculate an effective address.
int getEffectiveAddress(final Resource r, final int x) {
  return x == 0 ? r.memory[r.PR] : (r.memory[r.PR] + r.getGR(x)) & 0xffff;
}

/// Calculate a flag.
///
/// ```
/// void foo(Resource r) {
///   final v = r.memory[r.PR];
///   r.PR += 1;
///
///   final f = Flag(v);
///   r.FR = f.sign | f.zero;
/// }
/// ```
class Flag {
  /// base value;
  final int _value;

  Flag(this._value);

  int get sign => this._value & (1 << (wordSize - 1)) > 0 ? signFlag : 0;
  int get zero => this._value == 0 ? zeroFlag : 0;
}
