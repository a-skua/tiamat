import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of COMET2, named ADDA
///
/// That's 2 words instruction,
/// add(arithmetic) from effective address to `r`.
/// Syntax: ADDA r,adr,x
void addArithmetic(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final result = gr[op.r].signed + r.memory[adr].toSigned(r.memory.bits);
  final f = ArithmeticFlagger(result);

  gr[op.r].value = result;
  fr.value = f.overflow | f.sign | f.zero;
}

/// An instruction of COMET2, named ADDA
///
/// That's 1 word instruction,
/// add(arithmetic) from `r2` to `r1`.
/// Syntax: ADDA r1,r2
void addArithmeticGR(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final result = gr[op.r1].signed + gr[op.r2].signed;
  final f = ArithmeticFlagger(result);

  gr[op.r1].value = result;
  fr.value = f.overflow | f.sign | f.zero;
}
