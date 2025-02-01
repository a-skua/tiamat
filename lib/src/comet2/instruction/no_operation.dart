import '../resource/resource.dart';

/// An instruction of COMET2, named NOP.
///
/// That's one word instruction,
/// do nothing.
/// Syntax: NOP
Future<void> noOperation(final Resource r, Device _) async {
  r.count();
}
