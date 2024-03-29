import '../resource.dart';

/// An instruction of COMET2, named RET.
///
/// That's one word instruction,
/// pop on stack pointer to program register.
/// Syntax: RET
Future<void> returnFromSubroutine(final Resource r) async {
  final pr = r.programRegister;
  final sp = r.stackPointer;
  final ram = r.memory;

  pr.value = ram[sp.value];
  sp.value += 1;
}
