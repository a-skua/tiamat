import '../../resource/resource.dart';

/// An instruction of CASL2, named NOP.
///
/// That's 1 word instruction, do nothing.
/// Syntax: `NOP`
void noOperation(final Resource r) {
  r.PR += 1;
}
