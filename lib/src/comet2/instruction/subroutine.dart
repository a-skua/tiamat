import '../resource/resource.dart';
import 'util.dart';

/// An instruction of COMET2, named CALL.
///
/// That's two words instruction,
/// set return address on stack pointer and
/// set effective address to program register.
/// Syntax: CALL adr,x
Future<void> callSubroutine(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  r.push(r.pr);
  r.pr = adr;
}

/// An instruction of COMET2, named RET.
///
/// That's one word instruction,
/// pop on stack pointer to program register.
/// Syntax: RET
Future<void> returnFromSubroutine(final Resource r, Device _) async {
  r.pr = r.pop();
}
