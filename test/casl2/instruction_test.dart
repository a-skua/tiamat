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

  test('CPA', () {
    final cc = Casl2();

    expect(cpa('', 'GR1,GR2').code, equals([0x4412]));
    expect(cpa('', 'GR1,#FF22').code, equals([0x4010, 0xff22]));
    expect(cpa('', 'GR5,#ABCD,GR2').code, equals([0x4052, 0xabcd]));

    const asm = '; cpa test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR0,1234\n'
        '\tLAD\tGR1,#1234\n'
        '\tCPA\tGR0,GR1\n'
        '\tCPA\tGR1,LABEL\n'
        'LABEL\tRET\n'
        '\tEND\n';

    expect(
        cc.compile(asm),
        equals([
          0x1200,
          1234,
          0x1210,
          0x1234,
          0x4401,
          0x4010,
          7,
          0x8100,
        ]));
  });

  test('CPL', () {
    final cc = Casl2();

    expect(cpl('', 'GR1,GR2').code, equals([0x4512]));
    expect(cpl('', 'GR7,#ABCD').code, equals([0x4170, 0xabcd]));
    expect(cpl('', 'GR6,1234,GR5').code, equals([0x4165, 1234]));

    const asm = '; cpl test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR0,1234\n'
        '\tLAD\tGR1,#1234\n'
        '\tCPL\tGR0,GR1\n'
        '\tCPL\tGR1,LABEL\n'
        'LABEL\tRET\n'
        '\tEND\n';

    expect(
        cc.compile(asm),
        equals([
          0x1200,
          1234,
          0x1210,
          0x1234,
          0x4501,
          0x4110,
          7,
          0x8100,
        ]));
  });

  test('ADDA', () {
    final cc = Casl2();

    expect(adda('', 'GR2,GR4').code, equals([0x2424]));
    expect(adda('', 'GR7,#CCCC').code, equals([0x2070, 0xcccc]));
    expect(adda('', 'GR1,#EEEE,GR2').code, equals([0x2012, 0xeeee]));

    const asm = '; adda test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR0,1234\n'
        '\tLAD\tGR1,#1234\n'
        '\tADDA\tGR0,GR1\n'
        '\tADDA\tGR1,LABEL,GR2\n'
        'LABEL\tRET\n'
        '\tEND\n';

    expect(
        cc.compile(asm),
        equals([
          0x1200,
          1234,
          0x1210,
          0x1234,
          0x2401,
          0x2012,
          7,
          0x8100,
        ]));
  });

  test('ADDL', () {
    final cc = Casl2();

    expect(addl('', 'GR2,GR4').code, equals([0x2624]));
    expect(addl('', 'GR7,#CCCC').code, equals([0x2270, 0xcccc]));
    expect(addl('', 'GR1,#EEEE,GR2').code, equals([0x2212, 0xeeee]));

    const asm = '; addl test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR0,1234\n'
        '\tLAD\tGR1,#1234\n'
        '\tADDL\tGR0,GR1\n'
        '\tADDL\tGR1,LABEL,GR2\n'
        'LABEL\tRET\n'
        '\tEND\n';

    expect(
        cc.compile(asm),
        equals([
          0x1200,
          1234,
          0x1210,
          0x1234,
          0x2601,
          0x2212,
          7,
          0x8100,
        ]));
  });

  test('SUBA', () {
    final cc = Casl2();

    expect(suba('', 'GR2,GR4').code, equals([0x2524]));
    expect(suba('', 'GR7,#CCCC').code, equals([0x2170, 0xcccc]));
    expect(suba('', 'GR1,#EEEE,GR2').code, equals([0x2112, 0xeeee]));

    const asm = '; suba test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR0,1234\n'
        '\tLAD\tGR1,#1234\n'
        '\tSUBA\tGR0,GR1\n'
        '\tSUBA\tGR1,LABEL,GR2\n'
        'LABEL\tRET\n'
        '\tEND\n';

    expect(
        cc.compile(asm),
        equals([
          0x1200,
          1234,
          0x1210,
          0x1234,
          0x2501,
          0x2112,
          7,
          0x8100,
        ]));
  });

  test('SUBL', () {
    final cc = Casl2();

    expect(subl('', 'GR2,GR4').code, equals([0x2724]));
    expect(subl('', 'GR7,#CCCC').code, equals([0x2370, 0xcccc]));
    expect(subl('', 'GR1,#EEEE,GR2').code, equals([0x2312, 0xeeee]));

    const asm = '; subl test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR0,1234\n'
        '\tLAD\tGR1,#1234\n'
        '\tSUBL\tGR0,GR1\n'
        '\tSUBL\tGR1,LABEL,GR2\n'
        'LABEL\tRET\n'
        '\tEND\n';

    expect(
        cc.compile(asm),
        equals([
          0x1200,
          1234,
          0x1210,
          0x1234,
          0x2701,
          0x2312,
          7,
          0x8100,
        ]));
  });

  test('SLA', () {
    final cc = Casl2();

    expect(sla('FOO', 'GR2,1,GR3').code, equals([0x5023, 1]));
    expect(sla('FOO', 'GR2,1,GR3').label, equals('FOO'));
    expect(sla('', 'GR7,2').code, equals([0x5070, 2]));

    const asm = '; sla test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR0,#000F\n'
        '\tSLA\tGR0,#000F\n'
        '\tRET\n'
        '\tEND\n';

    expect(
      cc.compile(asm),
      equals([
        0x1200,
        0xf,
        0x5000,
        0xf,
        0x8100,
      ]),
    );
  });

  test('SRA', () {
    final cc = Casl2();

    expect(sra('FOO', 'GR2,1,GR3').code, equals([0x5123, 1]));
    expect(sra('FOO', 'GR2,1,GR3').label, equals('FOO'));
    expect(sra('', 'GR7,2').code, equals([0x5170, 2]));

    const asm = '; sla test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR0,#00F0\n'
        '\tSRA\tGR0,#000F\n'
        '\tRET\n'
        '\tEND\n';

    expect(
      cc.compile(asm),
      equals([
        0x1200,
        0xf0,
        0x5100,
        0xf,
        0x8100,
      ]),
    );
  });

  test('SLL', () {
    final cc = Casl2();

    expect(sll('FOO', 'GR2,1,GR3').code, equals([0x5223, 1]));
    expect(sll('FOO', 'GR2,1,GR3').label, equals('FOO'));
    expect(sll('', 'GR7,2').code, equals([0x5270, 2]));

    const asm = '; sla test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR0,#000F\n'
        '\tSLL\tGR0,#000F\n'
        '\tRET\n'
        '\tEND\n';

    expect(
      cc.compile(asm),
      equals([
        0x1200,
        0xf,
        0x5200,
        0xf,
        0x8100,
      ]),
    );
  });

  test('SRL', () {
    final cc = Casl2();

    expect(srl('FOO', 'GR2,1,GR3').code, equals([0x5323, 1]));
    expect(srl('FOO', 'GR2,1,GR3').label, equals('FOO'));
    expect(srl('', 'GR7,2').code, equals([0x5370, 2]));

    const asm = '; sla test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR0,#00F0\n'
        '\tSRL\tGR0,#000F\n'
        '\tRET\n'
        '\tEND\n';

    expect(
      cc.compile(asm),
      equals([
        0x1200,
        0xf0,
        0x5300,
        0xf,
        0x8100,
      ]),
    );
  });

  test('JUMP', () {
    final cc = Casl2();

    expect(jump('', '#FFFF').code, equals([0x6400, 0xffff]));
    expect(jump('', '1234,GR5').code, equals([0x6405, 1234]));
    expect(jump('FOO', '#FFFF').label, equals('FOO'));

    const asm = ';jump test\n'
        'TEST\tSTART\n'
        '\tJUMP\tEND\n'
        '\tNOP\n'
        '\tNOP\n'
        '\tNOP\n'
        '\tNOP\n'
        '\tNOP\n'
        'END\tRET\n'
        '\tEND';

    expect(
        cc.compile(asm),
        equals([
          0x6400,
          7,
          0,
          0,
          0,
          0,
          0,
          0x8100,
        ]));
  });

  test('JMI', () {
    final cc = Casl2();
    expect(jmi('', '2345').code, equals([0x6100, 2345]));
    expect(jmi('XXX', '2345').label, equals('XXX'));
    expect(jmi('', '#2345,GR5').code, equals([0x6105, 0x2345]));

    const asm = ';jmi test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR0,100\n'
        '\tLAD\tGR1,200\n'
        '\tCPA\tGR0,GR1\n'
        '\tJMI\tEND\n'
        '\tNOP\n'
        '\tNOP\n'
        'END\tRET\n'
        '\tEND';

    expect(
      cc.compile(asm),
      equals([
        0x1200,
        100,
        0x1210,
        200,
        0x4401,
        0x6100,
        9,
        0,
        0,
        0x8100,
      ]),
    );
  });

  test('JNZ', () {
    final cc = Casl2();
    expect(jnz('', '2345').code, equals([0x6200, 2345]));
    expect(jnz('XXX', '2345').label, equals('XXX'));
    expect(jnz('', '#2345,GR5').code, equals([0x6205, 0x2345]));

    const asm = ';jnz test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR0,100\n'
        '\tLAD\tGR1,200\n'
        '\tCPA\tGR0,GR1\n'
        '\tJNZ\tEND\n'
        '\tNOP\n'
        '\tNOP\n'
        'END\tRET\n'
        '\tEND';

    expect(
      cc.compile(asm),
      equals([
        0x1200,
        100,
        0x1210,
        200,
        0x4401,
        0x6200,
        9,
        0,
        0,
        0x8100,
      ]),
    );
  });

  test('JNE', () {
    final cc = Casl2();
    expect(jze('', '2345').code, equals([0x6300, 2345]));
    expect(jze('XXX', '2345').label, equals('XXX'));
    expect(jze('', '#2345,GR5').code, equals([0x6305, 0x2345]));

    const asm = ';jne test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR0,100\n'
        '\tLAD\tGR1,200\n'
        '\tCPA\tGR0,GR1\n'
        '\tJZE\tEND\n'
        '\tNOP\n'
        '\tNOP\n'
        'END\tRET\n'
        '\tEND';

    expect(
      cc.compile(asm),
      equals([
        0x1200,
        100,
        0x1210,
        200,
        0x4401,
        0x6300,
        9,
        0,
        0,
        0x8100,
      ]),
    );
  });

  test('JPL', () {
    final cc = Casl2();
    expect(jpl('', '2345').code, equals([0x6500, 2345]));
    expect(jpl('XXX', '2345').label, equals('XXX'));
    expect(jpl('', '#2345,GR5').code, equals([0x6505, 0x2345]));

    const asm = ';jpl test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR0,100\n'
        '\tLAD\tGR1,200\n'
        '\tCPA\tGR0,GR1\n'
        '\tJPL\tEND\n'
        '\tNOP\n'
        '\tNOP\n'
        'END\tRET\n'
        '\tEND';

    expect(
      cc.compile(asm),
      equals([
        0x1200,
        100,
        0x1210,
        200,
        0x4401,
        0x6500,
        9,
        0,
        0,
        0x8100,
      ]),
    );
  });

  test('JOV', () {
    final cc = Casl2();
    expect(jov('', '2345').code, equals([0x6600, 2345]));
    expect(jov('XXX', '2345').label, equals('XXX'));
    expect(jov('', '#2345,GR5').code, equals([0x6605, 0x2345]));

    const asm = ';jov test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR0,#FFFF\n'
        '\tLAD\tGR1,#FFFF\n'
        '\tADDL\tGR0,GR1\n'
        '\tJOV\tEND\n'
        '\tNOP\n'
        '\tNOP\n'
        'END\tRET\n'
        '\tEND';

    expect(
      cc.compile(asm),
      equals([
        0x1200,
        0xffff,
        0x1210,
        0xffff,
        0x2601,
        0x6600,
        9,
        0,
        0,
        0x8100,
      ]),
    );
  });

  test('PUSH', () {
    final cc = Casl2();
    expect(push('FOO', '#3333').code, equals([0x7000, 0x3333]));
    expect(push('FOO', '#3333').label, equals('FOO'));
    expect(push('', '4321,GR3').code, equals([0x7003, 4321]));

    const asm = ';push test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR1,#CCCC\n'
        '\tPUSH 0,GR1\n'
        '\tRET\n'
        '\tEND\n';

    expect(
      cc.compile(asm),
      equals([
        0x1210,
        0xcccc,
        0x7001,
        0,
        0x8100,
      ]),
    );
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

  test('AND', () {
    final cc = Casl2();

    expect(and('FOO', 'GR1,100,GR2').code, equals([0x3012, 100]));
    expect(and('FOO', 'GR1,100,GR2').label, equals('FOO'));
    expect(and('', 'GR3,GR4').code, equals([0x3434]));

    const asm = '; and test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR1,100\n'
        '\tLAD\tGR2,200\n'
        '\tAND\tGR1,GR2\n'
        '\tAND\tGR2,BUF\n'
        '\tRET\n'
        'BUF\tDC\t200\n'
        '\tEND\n';

    expect(
      cc.compile(asm),
      equals([
        0x1210,
        100,
        0x1220,
        200,
        0x3412,
        0x3020,
        8,
        0x8100,
        200,
      ]),
    );
  });

  test('OR', () {
    final cc = Casl2();

    expect(or('FOO', 'GR1,100,GR2').code, equals([0x3112, 100]));
    expect(or('FOO', 'GR1,100,GR2').label, equals('FOO'));
    expect(or('', 'GR3,GR4').code, equals([0x3534]));

    const asm = '; and test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR1,100\n'
        '\tLAD\tGR2,200\n'
        '\tOR\tGR1,GR2\n'
        '\tOR\tGR2,BUF\n'
        '\tRET\n'
        'BUF\tDC\t200\n'
        '\tEND\n';

    expect(
      cc.compile(asm),
      equals([
        0x1210,
        100,
        0x1220,
        200,
        0x3512,
        0x3120,
        8,
        0x8100,
        200,
      ]),
    );
  });

  test('XOR', () {
    final cc = Casl2();

    expect(xor('FOO', 'GR1,100,GR2').code, equals([0x3212, 100]));
    expect(xor('FOO', 'GR1,100,GR2').label, equals('FOO'));
    expect(xor('', 'GR3,GR4').code, equals([0x3634]));

    const asm = '; and test\n'
        'TEST\tSTART\n'
        '\tLAD\tGR1,100\n'
        '\tLAD\tGR2,200\n'
        '\tXOR\tGR1,GR2\n'
        '\tXOR\tGR2,BUF\n'
        '\tRET\n'
        'BUF\tDC\t200\n'
        '\tEND\n';

    expect(
      cc.compile(asm),
      equals([
        0x1210,
        100,
        0x1220,
        200,
        0x3612,
        0x3220,
        8,
        0x8100,
        200,
      ]),
    );
  });
}
