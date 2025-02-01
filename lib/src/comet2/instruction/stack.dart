import '../resource/resource.dart';
import 'util.dart';

/// An instruction of COMET2, named PUSH.
///
/// That's two words instruction,
/// push effective address to stack.
/// Syntax: PUSH adr,x
Future<void> push(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  r.push(adr);
}

/// An instruction of COMET2, named POP.
///
/// That's one word instruction,
/// pop value on stack pointer to register.
/// Syntax: POP r
Future<void> pop(final Resource r, Device _) async {
  final op = r.count();

  r.gr[op.r] = r.pop();
}
