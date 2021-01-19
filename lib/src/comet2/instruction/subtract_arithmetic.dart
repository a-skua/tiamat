import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of CASL2, named SUBA
///
/// That's 2 words instruction,
/// subtract(arithmetic) from effective address to `r`.
/// Syntax: SUBA r,adr,x
void subtractArithmetic(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final v1 = gr[op.r].signed;
  final v2 = r.memory[adr].toSigned(r.memory.bits);
  final result = v1 - v2;
  final f = ArithmeticFlagger(result);

  gr[op.r].value = result;
  fr.value = f.overflow | f.sign | f.zero;
}

/// An instruction of CASL2, named SUBA
///
/// That's 1 word instruction,
/// subtract(arithmetic) from `r2` to `r1`.
/// Syntax: SUBA r1,r2
void subtractArithmeticGR(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final v1 = gr[op.r1].signed;
  final v2 = gr[op.r2].signed;
  final result = v1 - v2;
  final f = ArithmeticFlagger(result);

  gr[op.r1].value = result;
  fr.value = f.overflow | f.sign | f.zero;
}
