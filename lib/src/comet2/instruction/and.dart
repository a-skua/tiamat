import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of CASL2, named AND.
///
/// That's 2 words instruction,
/// register and effective address.
/// Syntax: AND r,adr,x
void and(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final v1 = gr[op.r].value;
  final v2 = r.memory[adr];
  final result = v1 & v2;
  final f = ArithmeticFlagger(result);

  gr[op.r].value = result;
  fr.value = f.sign | f.zero;
}

/// An instruction of CASL2, named AND.
///
/// That's 1 word instruction,
/// 1st register and 2nd register.
/// Syntax: AND r1,r2
void andGR(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final v1 = gr[op.r1].value;
  final v2 = gr[op.r2].value;
  final result = v1 & v2;
  final f = ArithmeticFlagger(result);

  gr[op.r1].value = result;
  fr.value = f.sign | f.zero;
}
