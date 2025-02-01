import '../comet2.dart' show Real, Address;
import '../resource/resource.dart';

/// Real to Operand.
///
/// ## Bit Layout
/// |F  C|B  8|7  4|3  0|
/// | opecode | operand |
/// |    -    |r/r1|x/r2|
///
/// ## e.g.
/// ```
/// final (r1, r2) = 0x0012.operand; // (1, 2)
/// ```
extension RealToOperand on Real {
  (Real, Real) get operand => (r1, r2);
  Real get r1 => (this & 0x00f0) >> 4;
  Real get r2 => this & 0x000f;
  Real get r => r1;
  Real get x => r2;
}

/// Real to Opecode.
///
/// ## Bit Layout
/// |F  C|B  8|7  4|3  0|
/// | opecode | operand |
/// |main|sub |    -    |
///
/// ## e.g.
/// ```
/// final (main, sub) = 0x1200.opecode; // (1, 2)
/// ```
extension RealToOpecode on Real {
  (Real, Real) get opecode => (maincode, subcode);
  Real get maincode => (this & 0xf000) >> 12;
  Real get subcode => (this & 0x0f00) >> 8;
}

/// Real to Address.
///
/// ## Bit Layout
/// |F  C|B  8|7  4|3  0|
/// |      address      |
///
/// ## e.g.
/// ```
/// final address = adr.effectiveAddress(r.gr, op.x)
/// ```
extension RealToAddress on Real {
  Address effectiveAddress(final List<GR> gr, final Real x) {
    return x == 0 ? unsigned : (unsigned + gr[x].unsigned);
  }
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

/// Real to Arithmetic Flag.
extension RealToArithmeticFlag on Real {
  (OverflowFlag, SignFlag, ZeroFlag) get arithmeticFlag => (of, sf, zf);
  OverflowFlag get of => this < -0x8000 || this > 0x7fff;
  SignFlag get sf => signed < 0;
  ZeroFlag get zf => unsigned == 0;
}

/// Real to Logical Flag.
extension RealToLogicalFlag on Real {
  (OverflowFlag, SignFlag, ZeroFlag) get logicalFlag => (of, sf, zf);
  OverflowFlag get of => this < 0 || this > 0xffff;
  SignFlag get sf => signed < 0;
  ZeroFlag get zf => unsigned == 0;
}

(SignFlag, ZeroFlag) compare(final Real l, final Real r) {
  return (l < r, l == r);
}

/// Shift Left
(Real, OverflowFlag) shiftLeft(final Real v, final Real s) {
  final result = v << s;
  return (result, result & 0x10000 > 0);
}

/// Shift Right
(Real, OverflowFlag) shiftRight(final Real v, final Real s) {
  if (s == 0) {
    return (v, false);
  }

  final of = (v >> (s - 1)) & 1 > 0;
  return (v >> s, of);
}
