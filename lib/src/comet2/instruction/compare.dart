import '../resource/resource.dart';
import './util.dart' as util;

/// An instruction of COMET2, named CPA.
///
/// That's two words instruction,
/// compare(arithmetic) register and effective address.
/// Syntax: CPA r,adr,x
Future<void> compare(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  final (sf, zf) = util.compare(r.gr[op.r].signed, r.memory[adr].signed);

  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named CPA.
///
/// That's one word instruction,
/// compare(arithmetic) 1st register and 2nd register.
/// Syntax: CPA r1,r2
Future<void> compareGR(final Resource r, Device _) async {
  final op = r.count();

  final (sf, zf) = util.compare(r.gr[op.r1].signed, r.gr[op.r2].signed);

  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named CPL.
///
/// That's two words instruction,
/// compare(logical) register and effective address.
/// Syntax: CPL r,adr,x
Future<void> compareLogical(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  final (sf, zf) = util.compare(r.gr[op.r].unsigned, r.memory[adr].unsigned);

  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named CPL.
///
/// That's one word instruction,
/// compare(logical) 1st register and 2nd register.
/// Syntax: CPL r1,r2
Future<void> compareLogicalGR(final Resource r, Device _) async {
  final op = r.count();

  final (sf, zf) = util.compare(r.gr[op.r1].unsigned, r.gr[op.r2].unsigned);

  r.sf = sf;
  r.zf = zf;
}
