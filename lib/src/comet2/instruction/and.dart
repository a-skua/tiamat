import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of CASL2, named AND.
///
/// That's two words instruction,
/// the meaning register and effective address.
/// Syntax: AND r,adr,x
void and(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final result = gr[op.r].value & r.memory[adr];
  final f = ArithmeticFlagger(result);

  gr[op.r].value = result;
  fr.value = f.sign | f.zero;
}

/// An instruction of CASL2, named AND.
///
/// That's one word instruction,
/// the meaning 1st register and 2nd register.
/// Syntax: AND r1,r2
void andGR(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final result = gr[op.r1].value & gr[op.r2].value;
  final f = ArithmeticFlagger(result);

  gr[op.r1].value = result;
  fr.value = f.sign | f.zero;
}
