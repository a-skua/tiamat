import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named SRL.
///
/// That's two words instruction,
/// register shift right(logical) effective address.
/// Syntax: SRL r,adr,x
void shiftRightLogical(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final f = ShiftRightLogicalFlagger(gr[op.r].value, adr);

  gr[op.r].value = gr[op.r].value >> adr;
  fr.value = f.overflow | f.sign | f.zero;
}
