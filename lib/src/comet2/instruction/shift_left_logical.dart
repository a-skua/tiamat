import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of COMET2, named SLL.
///
/// That's two words instruction,
/// register shift left(logical) effective address.
/// Syntax: SLL r,adr,x
void shiftLeftLogical(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final result = gr[op.r].value << adr;
  final f = ShiftLeftLogicalFlagger(result);

  gr[op.r].value = result;
  fr.value = f.overflow | f.sign | f.zero;
}
