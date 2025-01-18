import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named SLA.
///
/// That's two words instruction,
/// register shift left(arithmetic) effective address.
/// Syntax: SLA r,adr,x
Future<void> shiftLeftArithmetic(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  final result = r.gr[op.r].signed << adr;
  final f = ShiftLeftArithmeticFlagger(result);

  r.gr[op.r] = result.unsigned;
  r.fr = f.overflow | f.sign | f.zero;
}

/// An instruction of COMET2, named SRA.
///
/// That's two words instruction,
/// register shift right(arithmetic) effective address.
/// Syntax: SRA r,adr,x
Future<void> shiftRightArithmetic(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  final f = ShiftRightArithmeticFlagger(r.gr[op.r].signed, adr);

  final result = r.gr[op.r].signed >> adr;
  r.gr[op.r] = result.unsigned;
  r.fr = f.overflow | f.sign | f.zero;
}

/// An instruction of COMET2, named SLL.
///
/// That's two words instruction,
/// register shift left(logical) effective address.
/// Syntax: SLL r,adr,x
Future<void> shiftLeftLogical(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  final result = r.gr[op.r].unsigned << adr;
  final f = ShiftLeftLogicalFlagger(result);

  r.gr[op.r] = result.unsigned;
  r.fr = f.overflow | f.sign | f.zero;
}

/// An instruction of COMET2, named SRL.
///
/// That's two words instruction,
/// register shift right(logical) effective address.
/// Syntax: SRL r,adr,x
Future<void> shiftRightLogical(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  final f = ShiftRightLogicalFlagger(r.gr[op.r].unsigned, adr);

  r.gr[op.r] = r.gr[op.r].unsigned >> adr;
  r.fr = f.overflow | f.sign | f.zero;
}
