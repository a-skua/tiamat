import '../resource.dart';
import 'util.dart';

/// An instruction of COMET2, named OR.
///
/// That's two words instruction,
/// register or effective address.
/// Syntax: OR r,adr,x
Future<void> or(final Resource r) async {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final adr = getEffectiveAddress(r, op.x);
  pr.value += 1;

  final result = gr[op.r].value | ram[adr];
  final f = ArithmeticFlagger(result);

  gr[op.r].value = result;
  fr.value = f.sign | f.zero;
}

/// An instruction of COMET2, named OR.
///
/// That's one word instruction,
/// 1st register or 2nd register.
/// Syntax: OR r1,r2
Future<void> orGR(final Resource r) async {
  final pr = r.programRegister;
  final gr = r.generalRegisters;
  final fr = r.flagRegister;
  final ram = r.memory;

  final op = Operand(ram[pr.value]);
  pr.value += 1;

  final result = gr[op.r1].value | gr[op.r2].value;
  final f = ArithmeticFlagger(result);

  gr[op.r1].value = result;
  fr.value = f.sign | f.zero;
}
