import 'dart:math';

import 'package:tiamat/src/instruction.dart';
import 'package:tiamat/src/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('call subroutine', () {
    final maskBits = 0xffff;

    test('without base', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 4; i++) {
        final pr = rand.nextInt(1 << 16);
        final adr = rand.nextInt(1 << 16);
        final sp = rand.nextInt(1 << 16) | 1;
        final op = 0x80 << 8;

        r.SP = sp;
        r.PR = pr;
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, adr);

        ins.callSubroutine(r);
        expect(r.SP, equals((sp - 1) & maskBits));
        expect(r.memory.getWord(r.SP), equals((pr + 2) & maskBits));
        expect(r.PR, equals(adr));
      }
    });

    test('with base', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 4; i++) {
        final pr = rand.nextInt(1 << 16);
        final x = getX(0);
        final adr = rand.nextInt(1 << 15);
        final base = rand.nextInt(1 << 15);
        final sp = rand.nextInt(1 << 16) | 1;
        final op = (0x80 << 8) | x;

        r.SP = sp;
        r.PR = pr;
        r.setGR(x, base);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, adr);

        ins.callSubroutine(r);
        expect(r.SP, equals((sp - 1) & maskBits));
        expect(r.memory.getWord(r.SP), equals((pr + 2) & maskBits));
        expect(r.PR, equals((adr + base) & maskBits));
      }
    });
  });

  test('return from subroutine', () {
    final r = Resource();
    final ins = Instruction();
    final maskBits = 0xffff;

    for (var i = 0; i < 8; i++) {
      final sp = rand.nextInt(1 << 16);
      final pr = rand.nextInt(1 << 16);
      final op = 0x81 << 8;

      r.SP = sp;
      r.memory.setWord(r.PR, op);
      r.memory.setWord(sp, pr);

      ins.returnFromSubroutine(r);
      expect(r.SP, equals((sp + 1) & maskBits));
      expect(r.PR, equals(pr));
    }

    final pr = rand.nextInt(1 << 16);

    r.SP = 0xffff;
    r.memory.setWord(r.SP, pr);
    r.memory.setWord(r.PR, 0x81 << 8);

    ins.returnFromSubroutine(r);
    expect(r.SP, equals(0));
    expect(r.PR, equals(pr));
  });
}
