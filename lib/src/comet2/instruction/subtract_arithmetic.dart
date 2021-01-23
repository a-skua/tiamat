import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of COMET2, named SUBA
///
/// That's two words instruction,
/// subtract(arithmetic) effective address to register.
/// Syntax: SUBA r,adr,x
void subtractArithmetic(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final result = gr[op.r].signed - ram[adr].toSigned(ram.bits);
  final f = ArithmeticFlagger(result);

  gr[op.r].value = result;
  fr.value = f.overflow | f.sign | f.zero;
}

/// An instruction of COMET2, named SUBA
///
/// That's one word instruction,
/// subtract(arithmetic) 2nd register to 1st register.
/// Syntax: SUBA r1,r2
void subtractArithmeticGR(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final result = gr[op.r1].signed - gr[op.r2].signed;
  final f = ArithmeticFlagger(result);

  gr[op.r1].value = result;
  fr.value = f.overflow | f.sign | f.zero;
}
