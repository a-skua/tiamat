import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named PUSH.
///
/// That's two words instruction,
/// push effective address to stack.
/// Syntax: PUSH adr,x
Future<void> push(final Resource r) async {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final sp = r.stackPointer;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  sp.value -= 1;
  ram[sp.value] = adr;
}
