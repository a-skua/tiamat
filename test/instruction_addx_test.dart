import 'dart:math';

import 'package:tiamat/src/instruction.dart';
import 'package:tiamat/src/resource.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('add arithmetic memory', () {
    test('without base', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 3; i++) {
        final reg = rand.nextInt(8);
        final pr = rand.nextInt(1 << 15);
        final op = (0x20 << 8) + (reg << 4);
        final addr = rand.nextInt(1 << 15) + (1 << 15);
        final v1 = rand.nextInt(1 << 15);
        final v2 = rand.nextInt(1 << 15);

        r.PR = pr;
        r.setGR(reg, v1);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, addr);
        r.memory.setWord(addr, v2);
        ins.addArithmeticMemory(r);
        expect(r.getGR(reg), equals(v1 + v2));
        expect(r.PR, equals(pr + 2));
      }
    });

    test('with base', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 3; i++) {
        final reg = rand.nextInt(8);
        var baseReg = rand.nextInt(7) + 1;
        if (reg == baseReg) {
          baseReg = baseReg == 7 ? 1 : baseReg + 1;
        }
        final pr = rand.nextInt(1 << 15) + (1 << 15);
        final op = (0x20 << 8) + (reg << 4);
        final addr = rand.nextInt(1 << 14);
        final base = rand.nextInt(1 << 14);
        final v1 = rand.nextInt(1 << 15);
        final v2 = rand.nextInt(1 << 15);

        r.PR = pr;
        r.setGR(reg, v1);
        r.setGR(baseReg, base);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, addr);
        r.memory.setWord(addr, v2);
        ins.addArithmeticMemory(r);
        expect(r.getGR(reg), equals(v1 + v2));
        expect(r.PR, equals(pr + 2));
      }
    });

    group('flags', () {
      test('overflow', () {
        const maskBits = 0xffff;
        final r = Resource();
        final ins = Instruction();

        // (-) + (-)
        for (var i = 0; i < 4; i++) {
          final addr = rand.nextInt(1 << 15) + (1 << 15);
          final v1 = 1 << 15;
          final v2 = rand.nextInt(1 << 15) + (1 << 15);
          final gr = rand.nextInt(8);
          final op = (0x20 << 8) + (gr << 4);
          final result = (v1 + v2) & maskBits;

          r.setGR(gr, v1);
          r.memory.setWord(r.PR, op);
          r.memory.setWord(r.PR + 1, addr);
          r.memory.setWord(addr, v2);

          ins.addArithmeticMemory(r);
          expect(r.OF, equals(true));
          expect(r.SF, equals((result & (1 << 15)) > 0));
          expect(r.ZF, equals(result == 0));
        }

        // (+) + (+)
        for (var i = 0; i < 4; i++) {
          final addr = rand.nextInt(1 << 15) + (1 << 15);
          final v1 = 1 << 14;
          final v2 = rand.nextInt(1 << 14) + (1 << 14);
          final gr = rand.nextInt(8);
          final op = (0x20 << 8) + (gr << 4);
          final result = (v1 + v2) & maskBits;

          r.setGR(gr, v1);
          r.memory.setWord(r.PR, op);
          r.memory.setWord(r.PR + 1, addr);
          r.memory.setWord(addr, v2);

          ins.addArithmeticMemory(r);
          expect(r.getGR(gr), equals(result));
          expect(r.OF, equals(true));
          expect(r.SF, equals((result & (1 << 15)) > 0));
          expect(r.ZF, equals(result == 0));
        }
      });

      test('zero', () {
        final r = Resource();
        final ins = Instruction();

        var addr = rand.nextInt(1 << 15) + (1 << 15);
        var v1 = 1 << 15;
        var v2 = 1 << 15;
        var gr = rand.nextInt(8);
        var op = (0x20 << 8) + (gr << 4);

        r.setGR(gr, v1);
        r.memory.setWord(r.PR, op);
        r.memory.setWord(r.PR + 1, addr);
        r.memory.setWord(addr, v2);

        ins.addArithmeticMemory(r);
        expect(r.getGR(gr), equals(0));
        expect(r.OF, equals(true));
        expect(r.SF, equals(false));
        expect(r.ZF, equals(true));

        addr = rand.nextInt(1 << 15) + (1 << 15);
        v1 = 0;
        v2 = 0;
        gr = rand.nextInt(8);
        op = (0x20 << 8) + (gr << 4);

        r.setGR(gr, v1);
        r.memory.setWord(r.PR, op);
        r.memory.setWord(r.PR + 1, addr);
        r.memory.setWord(addr, v2);

        ins.addArithmeticMemory(r);
        expect(r.getGR(gr), equals(0));
        expect(r.OF, equals(false));
        expect(r.SF, equals(false));
        expect(r.ZF, equals(true));

        addr = rand.nextInt(1 << 15) + (1 << 15);
        v1 = 1 << 14;
        v2 = ((1 << 14) ^ -1) + 1;
        gr = rand.nextInt(8);
        op = (0x20 << 8) + (gr << 4);

        r.setGR(gr, v1);
        r.memory.setWord(r.PR, op);
        r.memory.setWord(r.PR + 1, addr);
        r.memory.setWord(addr, v2);

        ins.addArithmeticMemory(r);
        expect(r.getGR(gr), equals(0));
        expect(r.OF, equals(false));
        expect(r.SF, equals(false));
        expect(r.ZF, equals(true));
      });
    });
  });

  group('add arithmetic', () {
    test('default', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 8; i++) {
        final r1 = rand.nextInt(8);
        var r2 = rand.nextInt(8);
        if (r1 == r2) {
          r2 = r2 == 7 ? 0 : r2 + 1;
        }
        final pr = rand.nextInt(0xffff);

        final op = (0x24 << 8) + (r1 << 4) + r2;
        final v1 = rand.nextInt(1 << 15);
        final v2 = rand.nextInt(1 << 15);

        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory.setWord(pr, op);
        r.PR = pr;

        ins.addArithmetic(r);
        expect(r.PR, equals(pr + 1));
        expect(r.getGR(r1), equals(v1 + v2));
      }
    });

    group('flags', () {
      test('overflow', () {
        final r = Resource();
        final ins = Instruction();

        for (var i = 0; i < 4; i++) {
          final r1 = rand.nextInt(8);
          var r2 = rand.nextInt(8);
          if (r1 == r2) {
            r2 = r2 == 7 ? 0 : r2 + 1;
          }
          final pr = rand.nextInt(0xffff);

          final op = (0x24 << 8) + (r1 << 4) + r2;
          final v1 = 1 << 15;
          final v2 = rand.nextInt(1 << 15) + (1 << 15);

          r.setGR(r1, v1);
          r.setGR(r2, v2);
          r.memory.setWord(pr, op);
          r.PR = pr;
          final result = (v1 + v2) & 0xffff;

          ins.addArithmetic(r);
          expect(r.PR, equals(pr + 1));
          expect(r.getGR(r1), equals(result));
          expect(r.OF, equals(true));
          expect(r.SF, equals(false));
          expect(r.ZF, equals(result == 0));
        }

        for (var i = 0; i < 4; i++) {
          final r1 = rand.nextInt(8);
          var r2 = rand.nextInt(8);
          if (r1 == r2) {
            r2 = r2 == 7 ? 0 : r2 + 1;
          }
          final pr = rand.nextInt(0xffff);

          final op = (0x24 << 8) + (r1 << 4) + r2;
          final v1 = 1 << 14;
          final v2 = rand.nextInt(1 << 14) + (1 << 14);

          r.setGR(r1, v1);
          r.setGR(r2, v2);
          r.memory.setWord(pr, op);
          r.PR = pr;
          final result = (v1 + v2) & 0xffff;

          ins.addArithmetic(r);
          expect(r.PR, equals(pr + 1));
          expect(r.getGR(r1), equals(result));
          expect(r.OF, equals(true));
          expect(r.SF, equals(true));
          expect(r.ZF, equals(false));
        }

        for (var i = 0; i < 4; i++) {
          final r1 = rand.nextInt(8);
          var r2 = rand.nextInt(8);
          if (r1 == r2) {
            r2 = r2 == 7 ? 0 : r2 + 1;
          }
          final pr = rand.nextInt(0xffff);

          final op = (0x24 << 8) + (r1 << 4) + r2;
          final v1 = 1 << 15;
          final v2 = rand.nextInt(1 << 15) + (1 << 15);

          r.setGR(r1, v1);
          r.setGR(r2, v2);
          r.memory.setWord(pr, op);
          r.PR = pr;
          final result = (v1 + v2) & 0xffff;

          ins.addArithmetic(r);
          expect(r.PR, equals(pr + 1));
          expect(r.getGR(r1), equals(result));
          expect(r.OF, equals(true));
          expect(r.SF, equals((result & (1 << 15)) > 0));
          expect(r.ZF, equals(result == 0));
        }
      });

      test('sign', () {
        final r = Resource();
        final ins = Instruction();

        final r1 = rand.nextInt(8);
        var r2 = rand.nextInt(8);
        if (r1 == r2) {
          r2 = r2 == 7 ? 0 : r2 + 1;
        }

        final op = (0x24 << 8) + (r1 << 4) + r2;
        var v1 = 0;
        var v2 = rand.nextInt(1 << 15) + (1 << 15);
        var result = (v1 + v2) & 0xffff;

        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory.setWord(r.PR, op);

        ins.addArithmetic(r);
        expect(r.getGR(r1), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals(true));
        expect(r.ZF, equals(false));

        v1 = rand.nextInt(1 << 15);
        v2 = 0;
        result = (v1 + v2) & 0xffff;

        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory.setWord(r.PR, op);

        ins.addArithmetic(r);
        expect(r.getGR(r1), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals(false));
        expect(r.ZF, equals(result == 0));
      });

      test('zero', () {
        final r = Resource();
        final ins = Instruction();

        final r1 = rand.nextInt(8);
        var r2 = rand.nextInt(8);
        if (r1 == r2) {
          r2 = r2 == 7 ? 0 : r2 + 1;
        }

        final op = (0x24 << 8) + (r1 << 4) + r2;
        var v1 = 1 << 15;
        var v2 = 1 << 15;

        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory.setWord(r.PR, op);

        ins.addArithmetic(r);
        expect(r.getGR(r1), equals(0));
        expect(r.OF, equals(true));
        expect(r.SF, equals(false));
        expect(r.ZF, equals(true));

        v1 = 0;
        v2 = 0;

        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory.setWord(r.PR, op);

        ins.addArithmetic(r);
        expect(r.getGR(r1), equals(0));
        expect(r.OF, equals(false));
        expect(r.SF, equals(false));
        expect(r.ZF, equals(true));
      });
    });
  });
}
