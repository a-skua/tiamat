import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of CASL2, named ADDL.
///
/// That's 2 words instruction,
/// add(logical) from effective address to register.
/// Syntax: ADDL r,addr,x
void addLogical(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final v1 = gr[op.r].value;
  final v2 = r.memory[adr];
  final result = v1 + v2;
  final f = LogicalFlagger(result);

  gr[op.r].value = result;
  fr.value = f.overflow | f.sign | f.zero;
}

/// An instruction of CASL2, named ADDL.
///
/// That's 1 word instruction,
/// add(logical) from 2nd register to 1st register.
/// Syntax: ADDL r1,r2
void addLogicalGR(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;

  final op = Operand(r.memory[pr.value]);
  pr.value += 1;

  final v1 = gr[op.r1].value;
  final v2 = gr[op.r2].value;
  final result = v1 + v2;
  final f = LogicalFlagger(result);

  gr[op.r1].value = result;
  fr.value = f.overflow | f.sign | f.zero;
}
