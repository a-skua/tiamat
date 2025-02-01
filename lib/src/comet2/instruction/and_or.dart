import '../resource/resource.dart';
import './util.dart';

/// An instruction of COMET2, named AND.
///
/// That's two words instruction,
/// register and effective address.
/// Syntax: AND r,adr,x
Future<void> and(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  final result = r.gr[op.r].unsigned & r.memory[adr].unsigned;
  final (_, sf, zf) = result.logicalFlag;

  r.gr[op.r] = result;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named AND.
///
/// That's one word instruction,
/// 1st register and 2nd register.
/// Syntax: AND r1,r2
Future<void> andGR(final Resource r, Device _) async {
  final op = r.count();

  final result = r.gr[op.r1].unsigned & r.gr[op.r2].unsigned;
  final (_, sf, zf) = result.logicalFlag;

  r.gr[op.r1] = result;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named OR.
///
/// That's two words instruction,
/// register or effective address.
/// Syntax: OR r,adr,x
Future<void> or(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  final result = r.gr[op.r].unsigned | r.memory[adr].unsigned;
  final (_, sf, zf) = result.logicalFlag;

  r.gr[op.r] = result;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named OR.
///
/// That's one word instruction,
/// 1st register or 2nd register.
/// Syntax: OR r1,r2
Future<void> orGR(final Resource r, Device _) async {
  final op = r.count();

  final result = r.gr[op.r1].unsigned | r.gr[op.r2].unsigned;
  final (_, sf, zf) = result.logicalFlag;

  r.gr[op.r1] = result;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named XOR.
///
/// That's two words instruction,
/// register or(exclusive) effective address.
/// Syntax: XOR r,adr,x
Future<void> exclusiveOr(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  final result = r.gr[op.r].unsigned ^ r.memory[adr].unsigned;
  final (_, sf, zf) = result.logicalFlag;

  r.gr[op.r] = result;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named XOR.
///
/// That's one words instruction,
/// 1st register or(exclusive) 2nd register.
/// Syntax: XOR r1,r2
Future<void> exclusiveOrGR(final Resource r, Device _) async {
  final op = r.count();

  final result = r.gr[op.r1].unsigned ^ r.gr[op.r2].unsigned;
  final (_, sf, zf) = result.logicalFlag;

  r.gr[op.r1] = result;
  r.sf = sf;
  r.zf = zf;
}
