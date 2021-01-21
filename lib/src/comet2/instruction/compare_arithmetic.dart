import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of COMET2, named CPA.
///
/// That's two words instruction,
/// compare(arithmetic) register and effective address.
/// Syntax: CPA r,adr,x
void compareArithmetic(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final f = CompareFlagger(
    gr[op.r].signed,
    r.memory[adr].toSigned(r.memory.bits),
  );

  fr.value = f.sign | f.zero;
}

/// An instruction of COMET2, named CPA.
///
/// That's two words instruction,
/// compare(arithmetic) 1st register and 2nd register.
/// Syntax: CPA r1,r2
void compareArithmeticGR(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final f = CompareFlagger(gr[op.r1].signed, gr[op.r2].signed);

  fr.value = f.sign | f.zero;
}
