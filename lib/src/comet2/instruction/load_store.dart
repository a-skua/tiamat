import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named LD.
///
/// That's two words instruction,
/// load effective address to register.
/// Syntax: LD r,adr,x
Future<void> load(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  final result = r.memory[adr];
  final f = ArithmeticFlagger(result);

  r.gr[op.r] = result;
  r.fr = f.sign | f.zero;
}

/// An instruction of COMET2, named LD.
///
/// That's one word instruction,
/// load 2nd register to 1st register.
/// Syntax: LD r1,r2
Future<void> loadGR(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final result = r.gr[op.r2];
  final f = ArithmeticFlagger(result);

  r.gr[op.r1] = result;
  r.fr = f.sign | f.zero;
}

/// An instruction of COMET2, named ST.
///
/// That's two words instruction,
/// store register to effective address.
/// Syntax: ST r,adr,x
Future<void> store(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  r.memory[adr] = r.gr[op.r];
}

/// An instruction of COMET2, named LAD.
///
/// That's two words instruction,
/// load effective address(not value) to register.
/// Syntax: LAD r,adr,x
Future<void> loadAddress(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  r.gr[op.r] = adr;
}
