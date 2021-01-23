import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of COMET2, named CPL.
///
/// That's two words instruction,
/// compare(logical) register and effective address.
/// Syntax: CPL r,adr,x
void compareLogical(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final f = CompareFlagger(gr[op.r].value, ram[adr]);

  fr.value = f.sign | f.zero;
}

/// An instruction of COMET2, named CPL.
///
/// That's one word instruction,
/// compare(logical) 1st register and 2nd register.
/// Syntax: CPL r1,r2
void compareLogicalGR(final Resource r) {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final f = CompareFlagger(gr[op.r1].value, gr[op.r2].value);

  fr.value = f.sign | f.zero;
}
