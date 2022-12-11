import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named LAD.
///
/// That's two words instruction,
/// load effective address(not value) to register.
/// Syntax: LAD r,adr,x
Future<void> loadAddress(final Resource r) async {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  gr[op.r].value = adr;
}
