import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named LD.
///
/// That's two words instruction,
/// load effective address to register.
/// Syntax: LD r,adr,x
void load(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final result = ram[adr];
  final f = ArithmeticFlagger(result);

  gr[op.r].value = result;
  fr.value = f.sign | f.zero;
}

/// An instruction of COMET2, named LD.
///
/// That's one word instruction,
/// load 2nd register to 1st register.
/// Syntax: LD r1,r2
void loadGR(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final result = gr[op.r2].value;
  final f = ArithmeticFlagger(result);

  gr[op.r1].value = result;
  fr.value = f.sign | f.zero;
}
