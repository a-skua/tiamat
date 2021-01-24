import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named ADDL.
///
/// That's two words instruction,
/// add(logical) effective address to register.
/// Syntax: ADDL r,addr,x
void addLogical(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final result = gr[op.r].value + ram[adr];
  final f = LogicalFlagger(result);

  gr[op.r].value = result;
  fr.value = f.overflow | f.sign | f.zero;
}

/// An instruction of COMET2, named ADDL.
///
/// That's one word instruction,
/// add(logical) from 2nd register to 1st register.
/// Syntax: ADDL r1,r2
void addLogicalGR(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final result = gr[op.r1].value + gr[op.r2].value;
  final f = LogicalFlagger(result);

  gr[op.r1].value = result;
  fr.value = f.overflow | f.sign | f.zero;
}
