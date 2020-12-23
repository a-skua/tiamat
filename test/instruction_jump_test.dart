import 'dart:math';

import 'package:tiamat/src/instruction.dart';
import 'package:tiamat/src/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('unconditional jump', () {
    test('without base', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 4; i++) {
        final op = 0x6400;
        final adr = rand.nextInt(0x10000);

        r.memory.setWord(r.PR, op);
        r.memory.setWord(r.PR + 1, adr);

        ins.unconditionalJump(r);
        expect(r.PR, equals(adr));
      }
    });

    test('with base', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 4; i++) {
        final baseGR = getX(0);
        final op = 0x6400 | baseGR;
        final base = rand.nextInt(0x8000);
        final adr = rand.nextInt(0x8000);

        r.setGR(baseGR, base);
        r.memory.setWord(r.PR, op);
        r.memory.setWord(r.PR + 1, adr);

        ins.unconditionalJump(r);
        expect(r.PR, equals(base + adr));
      }
    });
  });

  group('jump on plus', () {
    test('without base', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 8; i++) {
        final op = 0x6500;
        final adr = rand.nextInt(0x10000);
        final pr = r.PR;

        r.FR = i;
        r.memory.setWord(r.PR, op);
        r.memory.setWord(r.PR + 1, adr);

        ins.jumpOnPlus(r);
        if (!r.SF && !r.ZF) {
          expect(r.PR, equals(adr));
        } else {
          expect(r.PR, equals((pr + 2) & 0xffff));
        }
      }
    });

    test('with base', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 8; i++) {
        final baseGR = getX(0);
        final op = 0x6500 | baseGR;
        final base = rand.nextInt(0x10000);
        final adr = rand.nextInt(0x10000);
        final pr = r.PR;

        r.setGR(baseGR, base);
        r.memory.setWord(r.PR, op);
        r.memory.setWord(r.PR + 1, adr);

        ins.jumpOnPlus(r);
        final e = (r.SF || r.ZF ? pr + 2 : base + adr) & 0xffff;
        expect(r.PR, equals(e));
      }
    });
  });
}
