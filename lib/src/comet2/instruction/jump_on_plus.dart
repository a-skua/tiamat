import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of COMET2, named JPL.
///
/// That's two words instruction,
/// jump to effective address when sign flag and zero flag are off.
/// Syntax: JPL adr,x
void jumpOnPlus(final Resource r) {
  final pr = r.programRegister;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  if (fr.isNotSign && fr.isNotZero) {
    pr.value = adr;
  }
}
