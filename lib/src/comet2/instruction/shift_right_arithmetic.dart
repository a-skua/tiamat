import '../../resource/resource.dart';
import 'util.dart';

/// SRA r,adr,x
void shiftRightArithmetic(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final f = ShiftRightArithmeticFlagger(gr[op.r].signed, adr);

  gr[op.r].value = gr[op.r].signed >> adr;
  fr.value = f.overflow | f.sign | f.zero;
}
