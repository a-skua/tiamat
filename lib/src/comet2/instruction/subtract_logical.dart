import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of COMET2, named SUBL.
///
/// That's 2 words instruction,
/// subtract(logical) from effective address to register.
/// Syntax: SUBL r,adr,x
void subtractLogical(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final result = gr[op.r].value - r.memory[adr];
  final f = LogicalFlagger(result);

  gr[op.r].value = result;
  fr.value = f.overflow | f.sign | f.zero;
}

/// An instruction of COMET2, named SUBL.
///
/// That's 1 word instruction,
/// subtract(logical) from 2nd register to 1st register.
/// Syntax: SUBL r1,r2
void subtractLogicalGR(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final result = gr[op.r1].value - gr[op.r2].value;
  final f = LogicalFlagger(result);

  gr[op.r1].value = result;
  fr.value = f.overflow | f.sign | f.zero;
}
