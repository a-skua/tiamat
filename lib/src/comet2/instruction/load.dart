import '../../resource/resource.dart';
import 'util.dart';

/// An instruction of CASL2, named LD.
///
/// That's 2 words instruction, load from effective address to `r`.
/// Syntax: `LD r,adr,x`
void load(final Resource r) {
  final cache = r.memory[r.PR];
  r.PR += 1;

  final x = cache & 0xf;
  final gr = (cache >> 4) & 0xf;
  final adr = getEffectiveAddress(r, x);
  r.PR += 1;

  final data = r.memory[adr];
  final flag = Flag(data);

  r.setGR(gr, data);
  r.FR = flag.sign | flag.zero;
}

/// An instruction of CASL2, named LD.
///
/// That's 1 word instruction, load from `r2` to `r1`.
/// Syntax: `LD r1,r2`
void loadGR(final Resource r) {
  final cache = r.memory[r.PR];
  r.PR += 1;

  final r2 = cache & 0xf;
  final r1 = (cache >> 4) & 0xf;

  final data = r.getGR(r2);
  final flag = Flag(data);
  r.setGR(r1, data);
  r.FR = flag.sign | flag.zero;
}
