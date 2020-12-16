import 'dart:math';

import 'package:tiamat/src/instruction.dart';
import 'package:tiamat/src/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('subtract arithmetic memory', () {
    test('without base', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final pr = rand.nextInt((1 << 15) - 1);
        final op = (0x21 << 8) + (gr << 4);
        final addr = rand.nextInt(1 << 15) + (1 << 15);
        final v1 = rand.nextInt(1 << 15);
        final v2 = rand.nextInt(1 << 15);
        final result = (v1 + (v2 ^ -1) + 1) & 0xffff;

        r.PR = pr;
        r.setGR(gr, v1);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, addr);
        r.memory.setWord(addr, v2);
        ins.subtractArithmeticMemory(r);
        expect(r.getGR(gr), equals(result));
        expect(r.PR, equals(pr + 2));
      }
    });

    test('with base', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final baseGR = getX(gr);
        final pr = rand.nextInt((1 << 15) - 1) + (1 << 15);
        final op = (0x21 << 8) + (gr << 4) + baseGR;
        final addr = rand.nextInt(1 << 14);
        final base = rand.nextInt(1 << 14);
        final v1 = rand.nextInt(1 << 15) + (1 << 15);
        final v2 = rand.nextInt(1 << 15) + (1 << 15);
        final result = (v1 + (((v2 ^ -1) + 1) & 0xffff)) & 0xffff;

        r.PR = pr;
        r.setGR(gr, v1);
        r.setGR(baseGR, base);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, addr);
        r.memory.setWord(base + addr, v2);
        ins.subtractArithmeticMemory(r);
        expect(r.getGR(gr), equals(result));
        expect(r.PR, equals(pr + 2));
      }
    });

    group('flags', () {
      test('overflow', () {
        final r = Resource();
        final ins = Instruction();

        // (+) - (-)
        for (var i = 0; i < 4; i++) {
          final addr = rand.nextInt(1 << 15) + (1 << 15);
          final v1 = rand.nextInt(1 << 15) | (1 << 14);
          final v2 =
              (rand.nextInt(1 << 15) + (1 << 15)) & (((1 << 14) ^ -1) & 0xffff);
          final gr = rand.nextInt(8);
          final op = (0x21 << 8) + (gr << 4);
          final result = (v1 + (v2 ^ -1) + 1) & 0xffff;

          r.setGR(gr, v1);
          r.memory.setWord(r.PR, op);
          r.memory.setWord(r.PR + 1, addr);
          r.memory.setWord(addr, v2);

          ins.subtractArithmeticMemory(r);
          expect(r.OF, equals(true));
          expect(r.SF, equals((result & (1 << 15)) > 0));
          expect(r.ZF, equals(result == 0));
        }

        // (-) - (+)
        for (var i = 0; i < 4; i++) {
          final addr = rand.nextInt(1 << 15) + (1 << 15);
          final v1 =
              (rand.nextInt(1 << 15) + (1 << 15)) & (((1 << 14) ^ -1) & 0xffff);
          final v2 = rand.nextInt(1 << 15) | (1 << 14);
          final gr = rand.nextInt(8);
          final op = (0x21 << 8) + (gr << 4);
          final result = (v1 + (v2 ^ -1) + 1) & 0xffff;

          r.setGR(gr, v1);
          r.memory.setWord(r.PR, op);
          r.memory.setWord(r.PR + 1, addr);
          r.memory.setWord(addr, v2);

          ins.subtractArithmeticMemory(r);
          expect(r.getGR(gr), equals(result));
          expect(r.OF, equals(true));
          expect(r.SF, equals((result & (1 << 15)) > 0));
          expect(r.ZF, equals(result == 0));
        }
      });

      test('sign', () {
        final r = Resource();
        final ins = Instruction();

        var addr = rand.nextInt(1 << 16) | (1 << 15);
        var gr = rand.nextInt(8);
        var op = (0x21 << 8) + (gr << 4);
        var v1 = rand.nextInt(1 << 14);
        var v2 = (rand.nextInt((1 << 14) - 1) + 1) | (1 << 14);
        var result = (v1 + (v2 ^ -1) + 1) & 0xffff;

        r.setGR(gr, v1);
        r.memory.setWord(r.PR, op);
        r.memory.setWord(r.PR + 1, addr);
        r.memory.setWord(addr, v2);

        ins.subtractArithmeticMemory(r);
        expect(r.getGR(gr), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals(true));
        expect(r.ZF, equals(false));

        addr = rand.nextInt(1 << 16) | (1 << 15);
        gr = rand.nextInt(8);
        op = (0x21 << 8) + (gr << 4);
        v1 = (rand.nextInt((1 << 16) - 2) + 1) | (1 << 15);
        v2 = (1 << 15) + 1;
        result = (v1 + (v2 ^ -1) + 1) & 0xffff;

        r.setGR(gr, v1);
        r.memory.setWord(r.PR, op);
        r.memory.setWord(r.PR + 1, addr);
        r.memory.setWord(addr, v2);

        ins.subtractArithmeticMemory(r);
        expect(r.getGR(gr), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals(false));
        expect(r.ZF, equals(false));
      });

      test('zero', () {
        final r = Resource();
        final ins = Instruction();

        var addr = rand.nextInt(1 << 16) | (1 << 15);
        var v1 = rand.nextInt(15);
        var v2 = v1;
        var gr = rand.nextInt(8);
        var op = (0x21 << 8) + gr << 4;

        r.setGR(gr, v1);
        r.memory.setWord(r.PR, op);
        r.memory.setWord(r.PR + 1, addr);
        r.memory.setWord(addr, v2);

        ins.subtractArithmeticMemory(r);
        expect(r.getGR(gr), equals(0));
        expect(r.OF, equals(false));
        expect(r.SF, equals(false));
        expect(r.ZF, equals(true));

        addr = rand.nextInt(1 << 16) | (1 << 15);
        v1 = 1 << 15;
        v2 = v1;
        gr = rand.nextInt(8);
        op = (0x21 << 8) + gr << 4;

        r.setGR(gr, v1);
        r.memory.setWord(r.PR, op);
        r.memory.setWord(r.PR + 1, addr);
        r.memory.setWord(addr, v2);

        ins.subtractArithmeticMemory(r);
        expect(r.getGR(gr), equals(0));
        expect(r.OF, equals(true));
        expect(r.SF, equals(false));
        expect(r.ZF, equals(true));

        addr = rand.nextInt(1 << 16) | (1 << 15);
        v1 = 0;
        v2 = 0;
        gr = rand.nextInt(8);
        op = (0x21 << 8) + (gr << 4);

        r.memory.setWord(r.PR, op);
        r.memory.setWord(r.PR + 1, addr);
        r.memory.setWord(addr, v2);

        ins.subtractArithmeticMemory(r);
        expect(r.getGR(gr), equals(0));
        expect(r.OF, equals(false));
        expect(r.SF, equals(false));
        expect(r.ZF, equals(true));
      });
    });
  });
}
