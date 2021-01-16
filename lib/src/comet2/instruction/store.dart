import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of CASL2, named ST.
///
/// That's 2 words instruction, store 'r' to effective address.
/// Syntax: ST r,adr,x
void store(final Resource r) {
  final cache = r.memory[r.PR];
  r.PR += 1;

  final x = cache & 0xf;
  final gr = (cache >> 4) & 0xf;
  final adr = getEffectiveAddress(r, x);
  r.PR += 1;

  r.memory[adr] = r.getGR(gr);
}
