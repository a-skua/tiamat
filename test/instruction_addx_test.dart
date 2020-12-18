import 'dart:math';

import 'package:tiamat/src/instruction.dart';
import 'package:tiamat/src/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('add arithmetic memory', () {
    test('without base', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final pr = rand.nextInt((1 << 15) - 1);
        final op = (0x20 << 8) + (gr << 4);
        final addr = rand.nextInt(1 << 16) | (1 << 15);
        final v1 = rand.nextInt(1 << 15);
        final v2 = rand.nextInt(1 << 15);

        r.PR = pr;
        r.setGR(gr, v1);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, addr);
        r.memory.setWord(addr, v2);
        ins.addArithmeticMemory(r);
        expect(r.getGR(gr), equals(v1 + v2));
        expect(r.PR, equals(pr + 2));
      }
    });

    test('with base', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final baseGR = getX(gr);
        final pr = rand.nextInt((1 << 16) - 1) | (1 << 15);
        final op = (0x20 << 8) + (gr << 4) + baseGR;
        final addr = rand.nextInt(1 << 14);
        final base = rand.nextInt(1 << 14);
        final v1 = rand.nextInt(1 << 15);
        final v2 = rand.nextInt(1 << 15);

        r.PR = pr;
        r.setGR(gr, v1);
        r.setGR(baseGR, base);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, addr);
        r.memory.setWord(base + addr, v2);
        ins.addArithmeticMemory(r);
        expect(r.getGR(gr), equals((v1 + v2) & 0xffff));
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
          final addr = rand.nextInt(1 << 16) | (1 << 15);
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

      test('sign', () {
        final r = Resource();
        final ins = Instruction();

        var addr = rand.nextInt(1 << 16);
        var gr = rand.nextInt(8);
        var op = (0x20 << 8) + (gr << 4);
        var v1 = 0;
        var v2 = rand.nextInt(1 << 16) | (1 << 15);
        var result = v1 + v2;

        r.setGR(gr, v1);
        r.memory.setWord(r.PR, op);
        r.memory.setWord(r.PR + 1, addr);
        r.memory.setWord(addr, v2);

        ins.addArithmeticMemory(r);
        expect(r.getGR(gr), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals(true));
        expect(r.ZF, equals(false));

        addr = rand.nextInt(1 << 16);
        gr = rand.nextInt(8);
        op = (0x29 << 8) + (gr << 4);
        v1 = rand.nextInt(1 << 16) | (1 << 15);
        v2 = 0;
        result = v1 + v2;

        r.setGR(gr, v1);
        r.memory.setWord(r.PR, op);
        r.memory.setWord(r.PR + 1, addr);
        r.memory.setWord(addr, v2);

        ins.addArithmeticMemory(r);
        expect(r.getGR(gr), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals(true));
        expect(r.ZF, equals(false));
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
        final r2 = getX(r1, base: 0);
        final pr = rand.nextInt(0xffff);

        final op = (0x24 << 8) | (r1 << 4) | r2;
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
          final r2 = getX(r1, base: 0);
          final pr = rand.nextInt(0xffff);

          final op = (0x24 << 8) | (r1 << 4) | r2;
          final v1 = 1 << 15;
          final v2 = rand.nextInt(1 << 16) | (1 << 15);

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
          final r2 = getX(r1, base: 0);
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
          final r2 = getX(r1, base: 0);
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
        final r2 = getX(r1, base: 0);

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
        final r2 = getX(r1, base: 0);

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

  group('add logical memory', () {
    const maskBits = (1 << 16) - 1;
    test('without base', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final op = (0x22 << 8) + (gr << 4);
        final pr = rand.nextInt((1 << 15) - 1);
        final addr = rand.nextInt(1 << 16) | (1 << 15);
        final v1 = rand.nextInt(1 << 16);
        final v2 = rand.nextInt(1 << 16);
        final result = (v1 + v2) & maskBits;

        r.PR = pr;
        r.setGR(gr, v1);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, addr);
        r.memory.setWord(addr, v2);

        ins.addLogicalMemory(r);
        expect(r.getGR(gr), equals(result));
        expect(r.PR, equals(pr + 2));
        expect(r.OF, equals((v1 + v2) > maskBits));
        expect(r.SF, equals((result & (1 << 15)) > 0));
        expect(r.ZF, equals(result == 0));
      }
    });

    test('with base', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final baseGR = getX(gr);
        final pr = rand.nextInt((1 << 16) - 2) | (1 << 15);
        final op = (0x22 << 8) + (gr << 4) + baseGR;
        final addr = rand.nextInt(1 << 14);
        final base = rand.nextInt(1 << 14);
        final v1 = rand.nextInt(1 << 16);
        final v2 = rand.nextInt(1 << 16);
        final result = (v1 + v2) & maskBits;

        r.PR = pr;
        r.setGR(gr, v1);
        r.setGR(baseGR, base);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, addr);
        r.memory.setWord(base + addr, v2);

        ins.addLogicalMemory(r);
        expect(r.getGR(gr), equals(result));
        expect(r.PR, equals(pr + 2));
        expect(r.OF, equals((v1 + v2) > maskBits));
        expect(r.SF, equals((result & (1 << 15)) > 0));
        expect(r.ZF, equals(result == 0));
      }
    });

    group('flags', () {
      test('overflow', () {
        final r = Resource();
        final ins = Instruction();

        for (var i = 0; i < 4; i++) {
          final gr = rand.nextInt(8);
          final op = (0x22 << 8) | (gr << 4);
          final addr = rand.nextInt(1 << 16) | (1 << 15);
          final v1 = rand.nextInt(1 << 16) | (1 << 15);
          final v2 = rand.nextInt(1 << 16) | (1 << 15);
          final result = (v1 + v2) & maskBits;

          r.setGR(gr, v1);
          r.memory.setWord(r.PR, op);
          r.memory.setWord(r.PR + 1, addr);
          r.memory.setWord(addr, v2);

          ins.addLogicalMemory(r);
          expect(r.getGR(gr), equals(result));
          expect(r.OF, equals(true));
          expect(r.SF, equals((result & (1 << 15)) > 0));
          expect(r.ZF, equals(result == 0));
        }
      });

      test('sign', () {
        final r = Resource();
        final ins = Instruction();

        for (var i = 0; i < 4; i++) {
          final gr = rand.nextInt(8);
          final op = (0x22 << 8) | (gr << 4);
          final addr = rand.nextInt(1 << 16) | (1 << 15);
          final v1 = rand.nextInt(1 << 15) | (1 << 14);
          final v2 = rand.nextInt(1 << 15) | (1 << 14);
          final result = (v1 + v2) & maskBits;

          r.setGR(gr, v1);
          r.memory.setWord(r.PR, op);
          r.memory.setWord(r.PR + 1, addr);
          r.memory.setWord(addr, v2);

          ins.addLogicalMemory(r);
          expect(r.getGR(gr), equals(result));
          expect(r.OF, equals((v1 + v2) > maskBits));
          expect(r.SF, equals(true));
          expect(r.ZF, equals(false));
        }
      });

      test('zero', () {
        final r = Resource();
        final ins = Instruction();

        for (var i = 0; i < 4; i++) {
          final gr = rand.nextInt(8);
          final op = (0x22 << 8) | (gr << 4);
          final addr = rand.nextInt(1 << 16) | (1 << 15);
          final v1 = rand.nextInt(1 << 16);
          final v2 = ((v1 ^ -1) + 1) & maskBits;
          final result = (v1 + v2) & maskBits;

          r.setGR(gr, v1);
          r.memory.setWord(r.PR, op);
          r.memory.setWord(r.PR + 1, addr);
          r.memory.setWord(addr, v2);

          ins.addLogicalMemory(r);
          expect(r.getGR(gr), equals(result));
          expect(r.OF, equals(true));
          expect(r.SF, equals(false));
          expect(r.ZF, equals(true));
        }
      });
    });
  });

  group('add logical', () {
    const maskBits = 0xffff;

    test('default', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final pr = rand.nextInt((1 << 16) - 1);

        final op = (0x26 << 8) | (r1 << 4) | r2;
        final v1 = rand.nextInt(1 << 16);
        final v2 = rand.nextInt(1 << 16);
        final raw = v1 + v2;
        final result = raw & maskBits;

        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory.setWord(pr, op);
        r.PR = pr;

        ins.addLogical(r);
        expect(r.getGR(r1), equals(result));
        expect(r.PR, equals(pr + 1));
        expect(r.OF, equals((raw & (maskBits << 16)) > 0));
        expect(r.SF, equals((result & (1 << 15)) > 0));
        expect(r.ZF, equals(result == 0));
      }
    });

    group('flags', () {
      test('overflow', () {
        final r = Resource();
        final ins = Instruction();

        for (var i = 0; i < 4; i++) {
          final r1 = rand.nextInt(8);
          final r2 = getX(r1, base: 0);
          final pr = rand.nextInt((1 << 16) - 1);

          final op = (0x26 << 8) | (r1 << 4) | r2;
          final v1 = rand.nextInt(1 << 16) | (1 << 15);
          final v2 = rand.nextInt(1 << 16) | (1 << 15);
          final raw = v1 + v2;
          final result = raw & maskBits;

          r.setGR(r1, v1);
          r.setGR(r2, v2);
          r.memory.setWord(pr, op);
          r.PR = pr;

          ins.addLogical(r);
          expect(r.getGR(r1), equals(result));
          expect(r.PR, equals(pr + 1));
          expect(r.OF, equals(true));
          expect(r.SF, equals((result & (1 << 15)) > 0));
          expect(r.ZF, equals(result == 0));
        }
      });

      test('sign', () {
        final r = Resource();
        final ins = Instruction();

        for (var i = 0; i < 4; i++) {
          final r1 = rand.nextInt(8);
          final r2 = getX(r1, base: 0);
          final pr = rand.nextInt((1 << 16) - 1);

          final op = (0x26 << 8) | (r1 << 4) | r2;
          final v1 = rand.nextInt(1 << 15) | (1 << 14);
          final v2 = rand.nextInt(1 << 15) | (1 << 14);
          final raw = v1 + v2;
          final result = raw & maskBits;

          r.setGR(r1, v1);
          r.setGR(r2, v2);
          r.memory.setWord(pr, op);
          r.PR = pr;

          ins.addLogical(r);
          expect(r.getGR(r1), equals(result));
          expect(r.PR, equals(pr + 1));
          expect(r.OF, equals(false));
          expect(r.SF, equals(true));
          expect(r.ZF, equals(false));
        }
      });

      test('zero', () {
        final r = Resource();
        final ins = Instruction();

        for (var i = 0; i < 4; i++) {
          final r1 = rand.nextInt(8);
          final r2 = getX(r1, base: 0);
          final pr = rand.nextInt((1 << 16) - 1);

          final op = (0x26 << 8) | (r1 << 4) | r2;
          final v1 = rand.nextInt(1 << 16);
          final v2 = ((v1 ^ -1) + 1) & maskBits;
          final raw = v1 + v2;
          final result = raw & maskBits;

          r.setGR(r1, v1);
          r.setGR(r2, v2);
          r.memory.setWord(pr, op);
          r.PR = pr;

          ins.addLogical(r);
          expect(r.getGR(r1), equals(result));
          expect(r.PR, equals(pr + 1));
          expect(r.OF, equals(true));
          expect(r.SF, equals(false));
          expect(r.ZF, equals(true));
        }
      });
    });
  });
}
