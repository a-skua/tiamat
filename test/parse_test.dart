import 'dart:math';

import 'package:tiamat/src/parse.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  test('NOP and RET', () {
    const asm = '; comment\n'
        '\tNOP\t; comment\n'
        '\tRET\n';

    final p = Parse();
    final code = p.exec(asm);

    expect(code, equals([0, 0x8100]));
  });

  test('NOP', () {
    final p = Parse();
    final actual = p.nop('LABEL');
    final expected = Token([0], label: 'LABEL');

    expect(actual.code, equals(expected.code));
    expect(actual.label, equals(expected.label));
    expect(actual.refLabel, equals(expected.refLabel));
  });

  test('RET', () {
    final p = Parse();
    final actual = p.ret('LABEL');
    final expected = Token([0x8100], label: 'LABEL');

    expect(actual.code, equals(expected.code));
    expect(actual.label, equals(expected.label));
    expect(actual.refLabel, equals(expected.refLabel));
  });

  test('LD', () {
    final p = Parse();

    expect(p.ld('', 'GR0,GR1').code, equals([0x1401]));
    expect(p.ld('', 'GR2,GR0').code, equals([0x1420]));
    expect(p.ld('', 'GR7,1234').code, equals([0x1070, 1234]));
    expect(p.ld('', 'GR6,#1234').code, equals([0x1060, 0x1234]));
    expect(p.ld('', 'GR4,#4321,GR5').code, equals([0x1045, 0x4321]));

    final actual = p.ld('LABEL', 'GR4,REF,GR5');
    final expected = Token([0x1045, 0], label: 'LABEL', refLabel: 'REF');
    expect(actual.code, equals(expected.code));
    expect(actual.label, equals(expected.label));
    expect(actual.refLabel, equals(expected.refLabel));

    const asm = '; ld test'
        '\tLD GR0,GR1\n'
        '\tLD GR2,#7777\n'
        '\tLD GR3,9999,GR4\n'
        '\tNOP ;no operation\n'
        '\tRET ;end of program';

    expect(
        p.exec(asm), equals([0x1401, 0x1020, 0x7777, 0x1034, 9999, 0, 0x8100]));
  });
}
