import '../resource/resource.dart';
import 'util.dart';

/// An instruction of COMET2, named ADDA
///
/// That's two words instruction,
/// add(arithmetic) effective address to register.
/// Syntax: ADDA r,adr,x
Future<void> addArithmetic(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  final result = r.gr[op.r].signed + r.memory[adr].signed;
  final f = ArithmeticFlagger(result);

  r.gr[op.r] = result;
  r.fr = f.overflow | f.sign | f.zero;
}

/// An instruction of COMET2, named ADDA
///
/// That's one word instruction,
/// add(arithmetic) 2nd register to 1st register.
/// Syntax: ADDA r1,r2
Future<void> addArithmeticGR(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final result = r.gr[op.r1].signed + r.gr[op.r2].signed;
  final f = ArithmeticFlagger(result);

  r.gr[op.r1] = result;
  r.fr = f.overflow | f.sign | f.zero;
}

/// An instruction of COMET2, named ADDL.
///
/// That's two words instruction,
/// add(logical) effective address to register.
/// Syntax: ADDL r,addr,x
Future<void> addLogical(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  final result = r.gr[op.r].unsigned + r.memory[adr].unsigned;
  final f = LogicalFlagger(result);

  r.gr[op.r] = result;
  r.fr = f.overflow | f.sign | f.zero;
}

/// An instruction of COMET2, named ADDL.
///
/// That's one word instruction,
/// add(logical) from 2nd register to 1st register.
/// Syntax: ADDL r1,r2
Future<void> addLogicalGR(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final result = r.gr[op.r1].unsigned + r.gr[op.r2].unsigned;
  final f = LogicalFlagger(result);

  r.gr[op.r1] = result;
  r.fr = f.overflow | f.sign | f.zero;
}

/// An instruction of COMET2, named SUBA
///
/// That's two words instruction,
/// subtract(arithmetic) effective address to register.
/// Syntax: SUBA r,adr,x
Future<void> subtractArithmetic(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  final result = r.gr[op.r].signed - r.memory[adr].signed;
  final f = ArithmeticFlagger(result);

  r.gr[op.r] = result;
  r.fr = f.overflow | f.sign | f.zero;
}

/// An instruction of COMET2, named SUBA
///
/// That's one word instruction,
/// subtract(arithmetic) 2nd register to 1st register.
/// Syntax: SUBA r1,r2
Future<void> subtractArithmeticGR(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final result = r.gr[op.r1].signed - r.gr[op.r2].signed;
  final f = ArithmeticFlagger(result);

  r.gr[op.r1] = result;
  r.fr = f.overflow | f.sign | f.zero;
}

/// An instruction of COMET2, named SUBL.
///
/// That's two words instruction,
/// subtract(logical) effective address to register.
/// Syntax: SUBL r,adr,x
Future<void> subtractLogical(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  final result = r.gr[op.r].unsigned - r.memory[adr].unsigned;
  final f = LogicalFlagger(result);

  r.gr[op.r] = result;
  r.fr = f.overflow | f.sign | f.zero;
}

/// An instruction of COMET2, named SUBL.
///
/// That's 1 word instruction,
/// subtract(logical) from 2nd register to 1st register.
/// Syntax: SUBL r1,r2
Future<void> subtractLogicalGR(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final result = r.gr[op.r1].unsigned - r.gr[op.r2].unsigned;
  final f = LogicalFlagger(result);

  r.gr[op.r1] = result;
  r.fr = f.overflow | f.sign | f.zero;
}
