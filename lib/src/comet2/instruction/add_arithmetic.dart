import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named ADDA
///
/// That's two words instruction,
/// add(arithmetic) effective address to register.
/// Syntax: ADDA r,adr,x
void addArithmetic(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final result = gr[op.r].signed + ram[adr].toSigned(ram.bits);
  final f = ArithmeticFlagger(result);

  gr[op.r].value = result;
  fr.value = f.overflow | f.sign | f.zero;
}

/// An instruction of COMET2, named ADDA
///
/// That's one word instruction,
/// add(arithmetic) 2nd register to 1st register.
/// Syntax: ADDA r1,r2
void addArithmeticGR(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final result = gr[op.r1].signed + gr[op.r2].signed;
  final f = ArithmeticFlagger(result);

  gr[op.r1].value = result;
  fr.value = f.overflow | f.sign | f.zero;
}
