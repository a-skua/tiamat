import '../resource.dart';

/// An instruction of COMET2, named NOP.
///
/// That's one word instruction,
/// do nothing.
/// Syntax: NOP
void noOperation(final Resource r) {
  final pr = r.programRegister;
  pr.value += 1;
}
