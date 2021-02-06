// FIXME
import 'dart:math';

import 'package:tiamat/src/casl2/casl2.dart';
import 'package:tiamat/src/casl2/instruction.dart';
import 'package:tiamat/src/comet2/comet2.dart' show Comet2;
import 'package:test/test.dart';

import '../util/util.dart';

void main() {
  test('RET', () {
    final actual = ret('LABEL');
    final expected = Token([0x8100], label: 'LABEL');

    expect(actual.code, equals(expected.code));
    expect(actual.label, equals(expected.label));
    expect(actual.refLabel, equals(expected.refLabel));
  });

  test('POP', () {
    final cc = Casl2();
    expect(pop('BAR', 'GR3').code, equals([0x7130]));
    expect(pop('BAR', 'GR3').label, equals('BAR'));
    expect(pop('', 'GR4').code, equals([0x7140]));

    const asm = ';pop test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR1,1234\n'
        '\tPUSH\t0,GR1\n'
        '\tPOP\tGR0\n'
        '\tRET\n'
        '\tEND';

    expect(
      cc.compile(asm),
      equals([
        0x1210,
        1234,
        0x7001,
        0,
        0x7100,
        0x8100,
      ]),
    );
  });

  test('CALL', () {
    final cc = Casl2();
    expect(call('XXX', '#1233,GR2').code, equals([0x8002, 0x1233]));
    expect(call('XXX', '#1233,GR2').label, equals('XXX'));
    expect(call('', '200').code, equals([0x8000, 200]));

    const asm = ';call test\n'
        'TEST\tSTART\n'
        '\tCALL\tSUB\n'
        '\tLAD\tGR1,300\n'
        '\tRET\n'
        'SUB\tLAD\tGR0,200\n'
        '\tRET\n'
        '\tEND';

    expect(
      cc.compile(asm),
      equals([
        0x8000,
        5,
        0x1210,
        300,
        0x8100,
        0x1200,
        200,
        0x8100,
      ]),
    );
  });

  test('SVC', () {
    final cc = Casl2();

    expect(svc('FOO', '1,GR1').code, equals([0xf001, 1]));
    expect(svc('FOO', '1,GR1').label, equals('FOO'));
    expect(svc('', '2').code, equals([0xf000, 2]));

    const asm = '; svc test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR1,TEXT\n'
        '\tLAD\tGR2,3\n'
        '\tSVC\t2\n'
        '\tRET\n'
        'TEXT\tDC\t\'xxx\'\n'
        '\tEND\n';

    expect(
      cc.compile(asm),
      equals([
        0x1210,
        7,
        0x1220,
        3,
        0xf000,
        2,
        0x8100,
        0x78,
        0x78,
        0x78,
      ]),
    );
  });
}
