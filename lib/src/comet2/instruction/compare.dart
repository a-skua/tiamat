import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named CPA.
///
/// That's two words instruction,
/// compare(arithmetic) register and effective address.
/// Syntax: CPA r,adr,x
Future<void> compareArithmetic(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  final f = CompareFlagger(r.gr[op.r].signed, r.memory[adr].signed);

  r.fr = f.sign | f.zero;
}

/// An instruction of COMET2, named CPA.
///
/// That's one word instruction,
/// compare(arithmetic) 1st register and 2nd register.
/// Syntax: CPA r1,r2
Future<void> compareArithmeticGR(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final f = CompareFlagger(r.gr[op.r1].signed, r.gr[op.r2].signed);

  r.fr = f.sign | f.zero;
}

/// An instruction of COMET2, named CPL.
///
/// That's two words instruction,
/// compare(logical) register and effective address.
/// Syntax: CPL r,adr,x
Future<void> compareLogical(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  final f = CompareFlagger(r.gr[op.r].unsigned, r.memory[adr].unsigned);

  r.fr = f.sign | f.zero;
}

/// An instruction of COMET2, named CPL.
///
/// That's one word instruction,
/// compare(logical) 1st register and 2nd register.
/// Syntax: CPL r1,r2
Future<void> compareLogicalGR(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final f = CompareFlagger(r.gr[op.r1].unsigned, r.gr[op.r2].unsigned);

  r.fr = f.sign | f.zero;
}
