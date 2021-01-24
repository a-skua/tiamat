import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named RET.
///
/// That's one word instruction,
/// pop on stack pointer to program register.
/// Syntax: RET
void returnFromSubroutine(final Resource r) {
  final pr = r.programRegister;
  final sp = r.stackPointer;
  final ram = r.memory;

  pr.value = ram[sp.value];
  sp.value += 1;
}
