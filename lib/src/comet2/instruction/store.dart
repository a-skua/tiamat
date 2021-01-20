import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of COMET2, named ST.
///
/// That's 2 words instruction, store 'r' to effective address.
/// Syntax: ST r,adr,x
void store(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  r.memory[adr] = gr[op.r].value;
}
