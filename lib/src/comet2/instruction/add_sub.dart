import '../resource/resource.dart';
import './util.dart';

/// An instruction of COMET2, named ADDA
///
/// That's two words instruction,
/// add(arithmetic) effective address to register.
/// Syntax: ADDA r,adr,x
Future<void> add(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  final result = r.gr[op.r].signed + r.memory[adr].signed;
  final (of, sf, zf) = result.flag;

  r.gr[op.r] = result;
  r.of = of;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named ADDA
///
/// That's one word instruction,
/// add(arithmetic) 2nd register to 1st register.
/// Syntax: ADDA r1,r2
Future<void> addGR(final Resource r, Device _) async {
  final op = r.count();

  final result = r.gr[op.r1].signed + r.gr[op.r2].signed;
  final (of, sf, zf) = result.flag;

  r.gr[op.r1] = result;
  r.of = of;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named ADDL.
///
/// That's two words instruction,
/// add(logical) effective address to register.
/// Syntax: ADDL r,addr,x
Future<void> addLogical(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  final result = r.gr[op.r].unsigned + r.memory[adr].unsigned;
  final (of, sf, zf) = result.logicalFlag;

  r.gr[op.r] = result;
  r.of = of;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named ADDL.
///
/// That's one word instruction,
/// add(logical) from 2nd register to 1st register.
/// Syntax: ADDL r1,r2
Future<void> addLogicalGR(final Resource r, Device _) async {
  final op = r.count();

  final result = r.gr[op.r1].unsigned + r.gr[op.r2].unsigned;
  final (of, sf, zf) = result.logicalFlag;

  r.gr[op.r1] = result;
  r.of = of;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named SUBA
///
/// That's two words instruction,
/// subtract(arithmetic) effective address to register.
/// Syntax: SUBA r,adr,x
Future<void> subtract(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  final result = r.gr[op.r].signed - r.memory[adr].signed;
  final (of, sf, zf) = result.flag;

  r.gr[op.r] = result;
  r.of = of;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named SUBA
///
/// That's one word instruction,
/// subtract(arithmetic) 2nd register to 1st register.
/// Syntax: SUBA r1,r2
Future<void> subtractGR(final Resource r, Device _) async {
  final op = r.count();

  final result = r.gr[op.r1].signed - r.gr[op.r2].signed;
  final (of, sf, zf) = result.flag;

  r.gr[op.r1] = result;
  r.of = of;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named SUBL.
///
/// That's two words instruction,
/// subtract(logical) effective address to register.
/// Syntax: SUBL r,adr,x
Future<void> subtractLogical(final Resource r, Device _) async {
  final op = r.count();
  final adr = r.count().effectiveAddress(r.gr, op.x);

  final result = r.gr[op.r].unsigned - r.memory[adr].unsigned;
  final (of, sf, zf) = result.logicalFlag;

  r.gr[op.r] = result;
  r.of = of;
  r.sf = sf;
  r.zf = zf;
}

/// An instruction of COMET2, named SUBL.
///
/// That's 1 word instruction,
/// subtract(logical) from 2nd register to 1st register.
/// Syntax: SUBL r1,r2
Future<void> subtractLogicalGR(final Resource r, Device _) async {
  final op = r.count();

  final result = r.gr[op.r1].unsigned - r.gr[op.r2].unsigned;
  final (of, sf, zf) = result.logicalFlag;

  r.gr[op.r1] = result;
  r.of = of;
  r.sf = sf;
  r.zf = zf;
}
