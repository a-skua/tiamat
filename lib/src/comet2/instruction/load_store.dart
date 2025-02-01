import '../resource/resource.dart';
import './util.dart';

/// An instruction of COMET2, named LD.
///
/// That's two words instruction,
/// load effective address to register.
/// Syntax: LD r,adr,x
Future<void> load(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  final result = r.memory[adr].unsigned;
  final (_, sf, zf) = result.logicalFlag;

  r.gr[op.r] = result;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named LD.
///
/// That's one word instruction,
/// load 2nd register to 1st register.
/// Syntax: LD r1,r2
Future<void> loadGR(final Resource r, Device _) async {
  final op = r.count();

  final result = r.gr[op.r2].unsigned;
  final (_, sf, zf) = result.logicalFlag;

  r.gr[op.r1] = result;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named ST.
///
/// That's two words instruction,
/// store register to effective address.
/// Syntax: ST r,adr,x
Future<void> store(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  r.memory[adr] = r.gr[op.r].unsigned;
}

/// An instruction of COMET2, named LAD.
///
/// That's two words instruction,
/// load effective address(not value) to register.
/// Syntax: LAD r,adr,x
Future<void> loadAddress(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  r.gr[op.r] = adr;
}
