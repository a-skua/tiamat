import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named SVC.
///
/// That's two words instruction,
/// call supsvcervisor function.
/// Syntax: SVC adr,x
Future<void> supervisorCall(final Resource r) async {
  final pr = r.programRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  await r.supervisorCall(adr);
}
