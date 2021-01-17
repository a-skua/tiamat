import '../../resource/resource.dart';
import '../../resource/flag.dart' show Flag;

/// Calculate an effective address.
int getEffectiveAddress(final Resource r, final int x) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  return x == 0 ? r.memory[pr.value] : (r.memory[pr.value] + gr[x].value);
}

/// Parse instruction word
///
/// |F  C|B  8|7  4|3  0|
/// | operand |r/r1|x/r2|
/// |main|sub |    |    |
class Operand {
  final int _value;
  const Operand(this._value);

  /// Get operand code.
  int get code => (this._value >> 8) & 0xff;

  /// Get r.
  int get r => (this._value >> 4) & 0xf;

  /// Get x.
  int get x => this._value & 0xf;

  /// Get r1.
  int get r1 => this.r;

  /// Get r2.
  int get r2 => this.x;
}

/// Calculate a flag.
///
/// ```
/// void foo(Resource r) {
///   final v = r.memory[r.programRegister.value];
///   r.programRegister.value += 1;
///
///   final f = Flagger(v);
///   r.flagRegister.value = f.sign | f.zero;
/// }
/// ```
class Flagger {
  /// base value;
  final int _value;

  const Flagger(this._value);

  /// Get sign flag.
  int get sign => this._value & 0x8000 > 0 ? Flag.sign : 0;

  /// Get zero flag.
  int get zero => this._value == 0 ? Flag.zero : 0;
}
