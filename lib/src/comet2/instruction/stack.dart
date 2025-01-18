import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named PUSH.
///
/// That's two words instruction,
/// push effective address to stack.
/// Syntax: PUSH adr,x
Future<void> push(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  r.sp -= 1;
  r.memory[r.sp] = adr;
}

/// An instruction of COMET2, named POP.
///
/// That's one word instruction,
/// pop value on stack pointer to register.
/// Syntax: POP r
Future<void> pop(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  r.gr[op.r] = r.memory[r.sp.unsigned];
  r.sp += 1;
}
