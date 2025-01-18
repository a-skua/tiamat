import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named CALL.
///
/// That's two words instruction,
/// set return address on stack pointer and
/// set effective address to program register.
/// Syntax: CALL adr,x
Future<void> callSubroutine(final Resource r, Device _) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  r.sp -= 1;
  r.memory[r.sp.unsigned] = r.pr;
  r.pr = adr;
}

/// An instruction of COMET2, named RET.
///
/// That's one word instruction,
/// pop on stack pointer to program register.
/// Syntax: RET
Future<void> returnFromSubroutine(final Resource r, Device _) async {
  r.pr = r.memory[r.sp.unsigned];
  r.sp += 1;
}
