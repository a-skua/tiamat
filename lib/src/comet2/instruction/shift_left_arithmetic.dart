import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named SLA.
///
/// That's two words instruction,
/// register shift left(arithmetic) effective address.
/// Syntax: SLA r,adr,x
Future<void> shiftLeftArithmetic(final Resource r) async {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final result = gr[op.r].signed << adr;
  final f = ShiftLeftArithmeticFlagger(result);

  gr[op.r].value = result;
  fr.value = f.overflow | f.sign | f.zero;
}
