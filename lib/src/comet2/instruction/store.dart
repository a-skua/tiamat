import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named ST.
///
/// That's two words instruction,
/// store register to effective address.
/// Syntax: ST r,adr,x
Future<void> store(final Resource r) async {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  ram[adr] = gr[op.r].value;
}
