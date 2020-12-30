import 'dart:math';

import 'package:tiamat/src/casl2.dart';
import 'package:tiamat/src/instruction.dart';
import 'package:tiamat/src/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  test('NOP and RET', () {
    const asm = '; comment\n'
        '\tNOP\t; comment\n'
        '\tRET\n';

    final p = Casl2();
    final code = p.compile(asm);

    expect(code, equals([0, 0x8100]));
  });

  test('NOP', () {
    final p = Casl2();
    final actual = p.nop('LABEL');
    final expected = Token([0], label: 'LABEL');

    expect(actual.code, equals(expected.code));
    expect(actual.label, equals(expected.label));
    expect(actual.refLabel, equals(expected.refLabel));
  });

  test('RET', () {
    final p = Casl2();
    final actual = p.ret('LABEL');
    final expected = Token([0x8100], label: 'LABEL');

    expect(actual.code, equals(expected.code));
    expect(actual.label, equals(expected.label));
    expect(actual.refLabel, equals(expected.refLabel));
  });

  test('LD', () {
    final p = Casl2();

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

    expect(p.compile(asm),
        equals([0x1401, 0x1020, 0x7777, 0x1034, 9999, 0, 0x8100]));
  });

  test('LAD', () {
    final p = Casl2();

    expect(p.lad('', 'GR3,#1234').code, equals([0x1230, 0x1234]));
    expect(p.lad('', 'GR2,1234,GR1').code, equals([0x1221, 1234]));
    expect(p.lad('', 'GR0,FOO,GR2').code, equals([0x1202, 0]));
    expect(p.lad('', 'GR1,#4321,GR7').code, equals([0x1217, 0x4321]));

    final a = p.lad('LABEL', 'GR0,ADDR,GR5');
    final e = Token([0x1205, 0], label: 'LABEL', refLabel: 'ADDR', refIndex: 1);
    expect(a.code, equals(e.code));
    expect(a.label, equals(e.label));
    expect(a.refLabel, equals(e.refLabel));
    expect(a.refIndex, equals(e.refIndex));

    const asm = '; lad test'
        'TEST\tSTART XXX\n'
        '\tLAD GR1,#1111\n'
        'XXX\tLD GR0,GR1\n'
        '\tLAD GR1,1111\n'
        '\tRET\n'
        '\tEND\n';
    final code = p.compile(asm);
    expect(code,
        equals([0x6400, 4, 0x1210, 0x1111, 0x1401, 0x1210, 1111, 0x8100]));

    final r = Resource();
    final ins = Instruction();
    for (var i = 0; i < code.length; i++) {
      r.memory.setWord(r.PR + i, code[i]);
    }
    ins.exec(r);
    expect(r.getGR(0), equals(0));
    expect(r.getGR(1), equals(1111));
    expect(r.getGR(2), equals(0));
    expect(r.getGR(3), equals(0));
    expect(r.getGR(4), equals(0));
    expect(r.getGR(5), equals(0));
    expect(r.getGR(6), equals(0));
    expect(r.getGR(7), equals(0));
    expect(r.PR, equals(0));
    expect(r.SP, equals(0));
  });

  test('START', () {
    final p = Casl2();

    expect(p.start('', '#1234').code, equals([0x6400, 0x1234]));
    expect(p.start('', '').code, equals([]));

    final a = p.start('FOO', 'BAR');
    final e = Token([0x6400, 0], label: 'FOO', refLabel: 'BAR', refIndex: 1);
    expect(a.code, equals(e.code));
    expect(a.label, equals(e.label));
    expect(a.refLabel, equals(e.refLabel));
    expect(a.refIndex, equals(e.refIndex));

    const asm = '; start test'
        'TEST\tSTART XXX\n'
        '\tLD GR0,1\n'
        'XXX\tLD GR1,GR0\n'
        '\tRET';
    expect(p.compile(asm), equals([0x6400, 4, 0x1000, 1, 0x1410, 0x8100]));
  });

  test('END', () {
    final p = Casl2();

    expect(p.end().code, equals([]));

    const asm = '; end test'
        'TEST\tSTART\n'
        '\tLD GR0,GR1\n'
        '\tRET\n'
        '\tEND\n';
    expect(p.compile(asm), equals([0x1401, 0x8100]));
  });

  test('ST', () {
    final cc = Casl2();

    expect(cc.st('', 'GR1,#12FF').code, equals([0x1110, 0x12ff]));
    expect(cc.st('', 'GR0,12,GR1').code, equals([0x1101, 12]));

    const asm = '; st test'
        'TEST\tSTART\n'
        '\tLAD\tGR0,#1234\n'
        '\tST\tGR0,#2345\n'
        '\tRET\n'
        '\tEND\n';

    expect(cc.compile(asm), equals([0x1200, 0x1234, 0x1100, 0x2345, 0x8100]));
  });

  test('CPA', () {
    final cc = Casl2();

    expect(cc.cpa('', 'GR1,GR2').code, equals([0x4412]));
    expect(cc.cpa('', 'GR1,#FF22').code, equals([0x4010, 0xff22]));
    expect(cc.cpa('', 'GR5,#ABCD,GR2').code, equals([0x4052, 0xabcd]));

    const asm = '; cpa test'
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

    expect(cc.cpl('', 'GR1,GR2').code, equals([0x4512]));
    expect(cc.cpl('', 'GR7,#ABCD').code, equals([0x4170, 0xabcd]));
    expect(cc.cpl('', 'GR6,1234,GR5').code, equals([0x4165, 1234]));

    const asm = '; cpl test'
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

    expect(cc.adda('', 'GR2,GR4').code, equals([0x2424]));
    expect(cc.adda('', 'GR7,#CCCC').code, equals([0x2070, 0xcccc]));
    expect(cc.adda('', 'GR1,#EEEE,GR2').code, equals([0x2012, 0xeeee]));

    const asm = '; adda test'
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

    expect(cc.addl('', 'GR2,GR4').code, equals([0x2624]));
    expect(cc.addl('', 'GR7,#CCCC').code, equals([0x2270, 0xcccc]));
    expect(cc.addl('', 'GR1,#EEEE,GR2').code, equals([0x2212, 0xeeee]));

    const asm = '; addl test'
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

    expect(cc.suba('', 'GR2,GR4').code, equals([0x2524]));
    expect(cc.suba('', 'GR7,#CCCC').code, equals([0x2170, 0xcccc]));
    expect(cc.suba('', 'GR1,#EEEE,GR2').code, equals([0x2112, 0xeeee]));

    const asm = '; suba test'
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

    expect(cc.subl('', 'GR2,GR4').code, equals([0x2724]));
    expect(cc.subl('', 'GR7,#CCCC').code, equals([0x2370, 0xcccc]));
    expect(cc.subl('', 'GR1,#EEEE,GR2').code, equals([0x2312, 0xeeee]));

    const asm = '; subl test'
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

  test('JUMP', () {
    final cc = Casl2();

    expect(cc.jump('', '#FFFF').code, equals([0x6400, 0xffff]));
    expect(cc.jump('', '1234,GR5').code, equals([0x6405, 1234]));
    expect(cc.jump('FOO', '#FFFF').label, equals('FOO'));

    const asm = ';jump test'
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
    expect(cc.jmi('', '2345').code, equals([0x6100, 2345]));
    expect(cc.jmi('XXX', '2345').label, equals('XXX'));
    expect(cc.jmi('', '#2345,GR5').code, equals([0x6105, 0x2345]));

    const asm = ';jmi test'
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
    expect(cc.jnz('', '2345').code, equals([0x6200, 2345]));
    expect(cc.jnz('XXX', '2345').label, equals('XXX'));
    expect(cc.jnz('', '#2345,GR5').code, equals([0x6205, 0x2345]));

    const asm = ';jnz test'
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
    expect(cc.jze('', '2345').code, equals([0x6300, 2345]));
    expect(cc.jze('XXX', '2345').label, equals('XXX'));
    expect(cc.jze('', '#2345,GR5').code, equals([0x6305, 0x2345]));

    const asm = ';jne test'
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
    expect(cc.jpl('', '2345').code, equals([0x6500, 2345]));
    expect(cc.jpl('XXX', '2345').label, equals('XXX'));
    expect(cc.jpl('', '#2345,GR5').code, equals([0x6505, 0x2345]));

    const asm = ';jpl test'
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
    expect(cc.jov('', '2345').code, equals([0x6600, 2345]));
    expect(cc.jov('XXX', '2345').label, equals('XXX'));
    expect(cc.jov('', '#2345,GR5').code, equals([0x6605, 0x2345]));

    const asm = ';jov test'
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
    expect(cc.push('FOO', '#3333').code, equals([0x7000, 0x3333]));
    expect(cc.push('FOO', '#3333').label, equals('FOO'));
    expect(cc.push('', '4321,GR3').code, equals([0x7003, 4321]));

    const asm = ';push test'
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
    expect(cc.pop('BAR', 'GR3').code, equals([0x7130]));
    expect(cc.pop('BAR', 'GR3').label, equals('BAR'));
    expect(cc.pop('', 'GR4').code, equals([0x7140]));

    const asm = ';pop test'
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
    expect(cc.call('XXX', '#1233,GR2').code, equals([0x8002, 0x1233]));
    expect(cc.call('XXX', '#1233,GR2').label, equals('XXX'));
    expect(cc.call('', '200').code, equals([0x8000, 200]));

    const asm = ';call test'
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
}
