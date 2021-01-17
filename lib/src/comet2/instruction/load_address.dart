import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of CASL2, named LAD.
///
/// That's 2 words instruction, load address.
/// Syntax: LAD r,adr,x
void loadAddress(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  gr[op.r].value = adr;
}
