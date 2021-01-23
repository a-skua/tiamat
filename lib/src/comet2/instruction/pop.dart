import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of COMET2, named POP.
///
/// That's one word instruction,
/// pop value on stack pointer to register.
/// Syntax: POP r
void pop(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final sp = r.stackPointer;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  gr[op.r].value = ram[sp.value];
  sp.value += 1;
}
