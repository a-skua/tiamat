import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named JMI.
///
/// That's two words instruction,
/// jump to effective address when sign flag is on.
/// Syntax: JMI adr,x
Future<void> jumpOnMinus(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  if (r.sf) {
    r.pr = adr;
  }
}

/// An instruction of COMET2, named JNZ.
///
/// That's two words instruction,
/// jump to effective address when zero flag is off.
/// Syntax: JNZ adr,x
Future<void> jumpOnNonZero(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  if (!r.zf) {
    r.pr = adr;
  }
}

/// An instruction of COMET2, named JZE.
///
/// That's two words instruction,
/// jump to effective address when zero flag is on.
/// Syntax: JZE adr,x
Future<void> jumpOnZero(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  if (r.zf) {
    r.pr = adr;
  }
}

/// An instruction of COMET2, named JUMP.
///
/// That's two words instruction,
/// jump to effective address.
/// Syntax: JUMP adr,x
Future<void> unconditionalJump(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  r.pr = adr;
}

/// An instruction of COMET2, named JPL.
///
/// That's two words instruction,
/// jump to effective address when sign flag and zero flag are off.
/// Syntax: JPL adr,x
Future<void> jumpOnPlus(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  if (!r.sf && !r.zf) {
    r.pr = adr;
  }
}

/// An instruction of COMET2, named JOV.
///
/// That's two words instruction,
/// jump to effective address when overflow flag is on.
/// Syntax: JOV adr,x
Future<void> jumpOnOverflow(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  if (r.of) {
    r.pr = adr;
  }
}
