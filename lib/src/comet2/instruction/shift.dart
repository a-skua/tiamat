import '../resource/resource.dart';
import './util.dart' as util;

/// An instruction of COMET2, named SLA.
///
/// That's two words instruction,
/// register shift left(arithmetic) effective address.
/// Syntax: SLA r,adr,x
Future<void> shiftLeft(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  final (result, of) = util.shiftLeft(r.gr[op.r].signed, adr);
  final (_, sf, zf) = result.flag;

  r.gr[op.r] = result.unsigned;
  r.of = of;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named SRA.
///
/// That's two words instruction,
/// register shift right(arithmetic) effective address.
/// Syntax: SRA r,adr,x
Future<void> shiftRight(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  final (result, of) = util.shiftRight(r.gr[op.r].signed, adr);
  final (_, sf, zf) = result.flag;

  r.gr[op.r] = result.unsigned;
  r.of = of;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named SLL.
///
/// That's two words instruction,
/// register shift left(logical) effective address.
/// Syntax: SLL r,adr,x
Future<void> shiftLeftLogical(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  final (result, of) = util.shiftLeft(r.gr[op.r].unsigned, adr);
  final (_, sf, zf) = result.logicalFlag;

  r.gr[op.r] = result.unsigned;
  r.of = of;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named SRL.
///
/// That's two words instruction,
/// register shift right(logical) effective address.
/// Syntax: SRL r,adr,x
Future<void> shiftRightLogical(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  final (result, of) = util.shiftRight(r.gr[op.r].unsigned, adr);
  final (_, sf, zf) = result.logicalFlag;

  r.gr[op.r] = result.unsigned;
  r.of = of;
  r.sf = sf;
  r.zf = zf;
}
