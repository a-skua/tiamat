import 'dart:math';

import 'package:tiamat/src/comet2/instruction/instruction.dart';
import 'package:tiamat/src/resource/resource.dart';
import 'package:test/test.dart';

import '../../util/util.dart';

void main() {
  final rand = Random();

  group('add logical memory', () {
    const maskBits = (1 << 16) - 1;
    test('without base', () {
      final r = Resource();

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
        r.memory[pr] = op;
        r.memory[pr + 1] = addr;
        r.memory[addr] = v2;

        addLogicalMemory(r);
        expect(r.getGR(gr), equals(result));
        expect(r.PR, equals(pr + 2));
        expect(r.OF, equals((v1 + v2) > maskBits));
        expect(r.SF, equals((result & (1 << 15)) > 0));
        expect(r.ZF, equals(result == 0));
      }
    });

    test('with base', () {
      final r = Resource();

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
        r.memory[pr] = op;
        r.memory[pr + 1] = addr;
        r.memory[base + addr] = v2;

        addLogicalMemory(r);
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

        for (var i = 0; i < 4; i++) {
          final gr = rand.nextInt(8);
          final op = (0x22 << 8) | (gr << 4);
          final addr = rand.nextInt(1 << 16) | (1 << 15);
          final v1 = rand.nextInt(1 << 16) | (1 << 15);
          final v2 = rand.nextInt(1 << 16) | (1 << 15);
          final result = (v1 + v2) & maskBits;

          r.setGR(gr, v1);
          r.memory[r.PR] = op;
          r.memory[r.PR + 1] = addr;
          r.memory[addr] = v2;

          addLogicalMemory(r);
          expect(r.getGR(gr), equals(result));
          expect(r.OF, equals(true));
          expect(r.SF, equals((result & (1 << 15)) > 0));
          expect(r.ZF, equals(result == 0));
        }
      });

      test('sign', () {
        final r = Resource();

        for (var i = 0; i < 4; i++) {
          final gr = rand.nextInt(8);
          final op = (0x22 << 8) | (gr << 4);
          final addr = rand.nextInt(1 << 16) | (1 << 15);
          final v1 = rand.nextInt(1 << 15) | (1 << 14);
          final v2 = rand.nextInt(1 << 15) | (1 << 14);
          final result = (v1 + v2) & maskBits;

          r.setGR(gr, v1);
          r.memory[r.PR] = op;
          r.memory[r.PR + 1] = addr;
          r.memory[addr] = v2;

          addLogicalMemory(r);
          expect(r.getGR(gr), equals(result));
          expect(r.OF, equals((v1 + v2) > maskBits));
          expect(r.SF, equals(true));
          expect(r.ZF, equals(false));
        }
      });

      test('zero', () {
        final r = Resource();

        for (var i = 0; i < 4; i++) {
          final gr = rand.nextInt(8);
          final op = (0x22 << 8) | (gr << 4);
          final addr = rand.nextInt(1 << 16) | (1 << 15);
          final v1 = rand.nextInt(1 << 16);
          final v2 = ((v1 ^ -1) + 1) & maskBits;
          final result = (v1 + v2) & maskBits;

          r.setGR(gr, v1);
          r.memory[r.PR] = op;
          r.memory[r.PR + 1] = addr;
          r.memory[addr] = v2;

          addLogicalMemory(r);
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
        r.memory[pr] = op;
        r.PR = pr;

        addLogical(r);
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
          r.memory[pr] = op;
          r.PR = pr;

          addLogical(r);
          expect(r.getGR(r1), equals(result));
          expect(r.PR, equals(pr + 1));
          expect(r.OF, equals(true));
          expect(r.SF, equals((result & (1 << 15)) > 0));
          expect(r.ZF, equals(result == 0));
        }
      });

      test('sign', () {
        final r = Resource();

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
          r.memory[pr] = op;
          r.PR = pr;

          addLogical(r);
          expect(r.getGR(r1), equals(result));
          expect(r.PR, equals(pr + 1));
          expect(r.OF, equals(false));
          expect(r.SF, equals(true));
          expect(r.ZF, equals(false));
        }
      });

      test('zero', () {
        final r = Resource();

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
          r.memory[pr] = op;
          r.PR = pr;

          addLogical(r);
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
