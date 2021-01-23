import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of COMET2, named CALL.
///
/// That's two words instruction,
/// set return address on stack pointer and
/// set effective address to program register.
/// Syntax: CALL adr,x
void callSubroutine(final Resource r) {
  final pr = r.programRegister;
  final sp = r.stackPointer;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  sp.value -= 1;
  ram[sp.value] = pr.value;
  pr.value = adr;
}
