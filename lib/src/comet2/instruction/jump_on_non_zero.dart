import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of COMET2, named JNZ.
///
/// That's two words instruction,
/// jump to effective address when zero flag is off.
/// Syntax: JNZ adr,x
void jumpOnNonZero(final Resource r) {
  final pr = r.programRegister;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  if (fr.isNotZero) {
    pr.value = adr;
  }
}
