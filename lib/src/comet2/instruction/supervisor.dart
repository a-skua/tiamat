import '../resource/resource.dart';
import '../../typedef/typedef.dart';
import '../../charcode/charcode.dart';
import 'util.dart';

/// An instruction of COMET2, named SVC.
///
/// That's two words instruction,
/// call supsvcervisor function.
/// Syntax: SVC adr,x
Future<void> supervisorCall(final Resource r, Device d) async {
  final op = Operand(r.memory[r.pr.unsigned]);
  r.pr += 1;

  final adr = getEffectiveAddress(r, op.x);
  r.pr += 1;

  return switch (adr) {
    1 => _read(r, d),
    2 => _write(r, d),
    _ => null,
  };
}

/// LAD     GR1,IBUF  ; buffer
/// LAD     GR2,32    ; length
/// SVC     1         ; input
Future<void> _read(Resource r, Device d) async {
  final buf = r.gr[1];
  final len = r.gr[2];

  final bin = switch (await d.read(len)) {
    Ok<String, dynamic> ok => ok.unwrap.reals,
    Err err => throw Exception(err.unwrap),
  };

  final max = len - 1;
  if (bin.length > max) {
    bin.removeRange(max, bin.length);
  }
  bin.add(-1);
  r.memory.setAll(buf, bin);
}

/// LAD     GR1,IBUF  ; buffer
/// LAD     GR2,32    ; length
/// SVC     2         ; output
Future<void> _write(Resource r, Device d) async {
  final buf = r.gr[1];
  final len = r.gr[2];

  final bin = r.memory.sublist(buf, buf + len);
  final eol = switch (bin.indexOf(-1)) {
    -1 => bin.length,
    int n => n,
  };
  bin.removeRange(eol, bin.length);
  switch (await d.write(bin.string)) {
    case Err e:
      throw Exception(e.unwrap);
    default:
  }
}
