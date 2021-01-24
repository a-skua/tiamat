import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named JUMP.
///
/// That's two words instruction,
/// jump to effective address.
/// Syntax: JUMP adr,x
void unconditionalJump(final Resource r) {
  final pr = r.programRegister;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  pr.value = adr;
}
