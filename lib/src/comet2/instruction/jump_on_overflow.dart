import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of COMET2, named JOV.
///
/// That's two words instruction,
/// jump to effective address when overflow flag is on.
/// Syntax: JOV adr,x
void jumpOnOverflow(final Resource r) {
  final pr = r.programRegister;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  if (fr.isOverflow) {
    pr.value = adr;
  }
}
