import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of CASL2, named LD.
///
/// That's 2 words instruction, load from effective address to `r`.
/// Syntax: `LD r,adr,x`
void load(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final data = r.memory[adr];
  final f = Flagger(data);

  gr[op.r].value = data;
  fr.value = f.sign | f.zero;
}

/// An instruction of CASL2, named LD.
///
/// That's 1 word instruction, load from `r2` to `r1`.
/// Syntax: `LD r1,r2`
void loadGR(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final data = gr[op.r2].value;
  final f = Flagger(data);

  gr[op.r1].value = data;
  fr.value = f.sign | f.zero;
}