import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named JMI.
///
/// That's two words instruction,
/// jump to effective address when sign flag is on.
/// Syntax: JMI adr,x
Future<void> jumpOnMinus(final Resource r) async {
  final pr = r.programRegister;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  if (fr.isSign) {
    pr.value = adr;
  }
}
