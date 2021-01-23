import '../../resource/resource.dart';
import '../../resource/flag.dart' show Flag;

/// Calculate an effective address.
int getEffectiveAddress(final Resource r, final int x) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final ram = r.memory;
  return x == 0 ? ram[pr.value] : (ram[pr.value] + gr[x].value);
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

/// Interface.
class Flagger {
  const Flagger();

  /// Get overflow flag.
  int get overflow => 0;

  /// Get sign flag.
  int get sign => 0;

  /// Get zero flag.
  int get zero => 0;
}

/// Calculate a flag when arithmetic.
///
/// ```
/// int getFlag(final int v) {
///   final f = ArithmeticFlagger(v);
///   return f.overflow | f.sign | f.zero;
/// }
/// ```
class ArithmeticFlagger extends Flagger {
  /// base value;
  final int _value;

  const ArithmeticFlagger(this._value);

  @override
  int get overflow =>
      this._value < -0x8000 || this._value > 0x7fff ? Flag.overflow : 0;

  @override
  int get sign => this._value & 0x8000 > 0 ? Flag.sign : 0;

  @override
  int get zero => this._value == 0 ? Flag.zero : 0;
}

/// Calculate a flag when logical.
///
/// ```
/// int getFlag(int v) {
///   final f = LogicalFlagger(v);
///   return f.overflow | f.sign | f.zero;
/// }
/// ```
class LogicalFlagger extends Flagger {
  final int _value;
  const LogicalFlagger(this._value);

  @override
  int get overflow =>
      this._value < 0 || this._value > 0xffff ? Flag.overflow : 0;

  @override
  int get zero => this._value == 0 ? Flag.zero : 0;
}

/// Calculate a compared flag.
///
/// ```
/// int getFlag(final int l, final int r) {
///   final f = CompareFlagger(l, r);
///   return f.sign | f.zero;
/// }
/// ```
class CompareFlagger extends Flagger {
  final int _left;
  final int _right;

  const CompareFlagger(this._left, this._right);

  @override
  int get sign => this._left < this._right ? Flag.sign : 0;

  @override
  int get zero => this._left == this._right ? Flag.zero : 0;
}

/// Calculate a shift left flag when arithmetic.
///
/// ```
/// int getFlag(final int v) {
///   final f = ShiftLeftArithmeticFlagger(v);
///   return f.overflow | f.sign | f.zero;
/// }
/// ```
class ShiftLeftArithmeticFlagger extends ArithmeticFlagger {
  const ShiftLeftArithmeticFlagger(final int value) : super(value);

  @override
  int get overflow => this._value & 0x10000 > 0 ? Flag.overflow : 0;
}

/// Calculate a shift right flag when arithmetic.
///
/// ```
/// int getFlag(final int v, final int s) {
///   final f = ShiftRightArithmeticFlagger(v, s);
///   return f.overflow | f.sign | f.zero;
/// }
/// ```
class ShiftRightArithmeticFlagger extends ArithmeticFlagger {
  final int _origin;
  final int _shift;

  const ShiftRightArithmeticFlagger(this._origin, this._shift)
      : super(_origin >> _shift);

  @override
  int get overflow {
    if (this._shift <= 0) {
      return 0;
    }
    final v = this._origin >> (this._shift - 1);

    return v & 1 > 0 ? Flag.overflow : 0;
  }
}

/// Calculate a shift left flag when logical.
///
/// ```
/// int getFlag(final int v) {
///   final f = ShiftLeftLogicalFlagger(v);
///   return f.overflow | f.sign | f.zero;
/// }
/// ```
class ShiftLeftLogicalFlagger extends LogicalFlagger {
  const ShiftLeftLogicalFlagger(final int value) : super(value);

  @override
  int get overflow => this._value & 0x10000 > 0 ? Flag.overflow : 0;
}

/// Calculate a shift right flag when logical.
///
/// ```
/// int getFlag(final int v, final int s) {
///   final f = ShiftRightLogicalFlagger(v, s);
///   return f.overflow | f.sign | f.zero;
/// }
/// ```
class ShiftRightLogicalFlagger extends LogicalFlagger {
  final int _origin;
  final int _shift;

  const ShiftRightLogicalFlagger(this._origin, this._shift)
      : super(_origin >> _shift);

  @override
  int get overflow {
    if (this._shift <= 0) {
      return 0;
    }
    final v = this._origin >> (this._shift - 1);

    return v & 1 > 0 ? Flag.overflow : 0;
  }
}
