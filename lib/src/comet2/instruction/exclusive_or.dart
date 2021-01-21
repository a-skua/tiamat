import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of COMET2, named XOR.
///
/// That's two words instruction,
/// the meaning register or(exclusive) effective address.
/// Syntax: XOR r,adr,x
void exclusiveOr(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final result = gr[op.r].value ^ r.memory[adr];
  final f = ArithmeticFlagger(result);

  gr[op.r].value = result;
  fr.value = f.sign | f.zero;
}

/// An instruction of COMET2, named XOR.
///
/// That's one words instruction,
/// the meaning 1st register or(exclusive) 2nd register.
/// Syntax: XOR r1,r2
void exclusiveOrGR(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final result = gr[op.r1].value ^ gr[op.r2].value;
  final f = ArithmeticFlagger(result);

  gr[op.r1].value = result;
  fr.value = f.sign | f.zero;
}
