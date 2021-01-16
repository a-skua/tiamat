import 'dart:math';

import 'package:tiamat/src/comet2/instruction/instruction.dart';
import 'package:tiamat/src/resource/resource.dart';
import 'package:test/test.dart';

import '../../util/util.dart';

void main() {
  final rand = Random();

  group('compare arithmetic memory', () {
    test('without base r>adr', () {
      final r = Resource();

      // r(+) > adr(-)
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final pr = rand.nextInt(0x10000);
        final op = 0x4000 | (gr << 4);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x8000);
        final v2 = rand.nextInt(0x10000) | 0x8000;

        r.PR = pr;
        r.setGR(gr, v1);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[adr] = v2;

        compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }

      // r(+) > adr(+)
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final pr = rand.nextInt(0x10000);
        final op = 0x4000 | (gr << 4);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x8000) | 0x4000;
        final v2 = rand.nextInt(0x4000);

        r.PR = pr;
        r.setGR(gr, v1);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[adr] = v2;

        compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }

      // r(-) > adr(-)
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final pr = rand.nextInt(0x10000);
        final op = 0x4000 | (gr << 4);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x100) | 0xff00;
        final v2 = rand.nextInt(0x100) | 0x8000;

        r.PR = pr;
        r.setGR(gr, v1);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[adr] = v2;

        compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }
    });

    test('with base r>adr', () {
      final r = Resource();

      // r(+) > adr(-)
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final op = 0x4000 | (gr << 4) | x;
        final pr = rand.nextInt(0x10000);
        final base = rand.nextInt(0x10000);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x8000);
        final v2 = rand.nextInt(0x10000) | 0x8000;

        r.PR = pr;
        r.setGR(gr, v1);
        r.setGR(x, base);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[(base + adr) & 0xffff] = v2;

        compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }

      // r(+) > adr(+)
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final op = 0x4000 | (gr << 4) | x;
        final pr = rand.nextInt(0x10000);
        final base = rand.nextInt(0x10000);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x8000) | 0x4000;
        final v2 = rand.nextInt(0x4000);

        r.PR = pr;
        r.setGR(gr, v1);
        r.setGR(x, base);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[(base + adr) & 0xffff] = v2;

        compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }

      // r(-) > adr(-)
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final op = 0x4000 | (gr << 4) | x;
        final pr = rand.nextInt(0x10000);
        final base = rand.nextInt(0x10000);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x100) | 0xff00;
        final v2 = rand.nextInt(0x100) | 0x8000;

        r.PR = pr;
        r.setGR(gr, v1);
        r.setGR(x, base);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[(base + adr) & 0xffff] = v2;

        compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }
    });

    test('without base r=adr', () {
      final r = Resource();

      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final pr = rand.nextInt(0x10000);
        final op = 0x4000 | (gr << 4);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x10000);
        final v2 = v1;

        r.PR = pr;
        r.setGR(gr, v1);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[adr] = v2;

        compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(true));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }
    });

    test('with base r=adr', () {
      final r = Resource();

      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final op = 0x4000 | (gr << 4) | x;
        final pr = rand.nextInt(0x10000);
        final base = rand.nextInt(0x10000);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x10000);
        final v2 = v1;

        r.PR = pr;
        r.setGR(gr, v1);
        r.setGR(x, base);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[(base + adr) & 0xffff] = v2;

        compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(true));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }
    });

    test('without base r<adr', () {
      final r = Resource();

      // r(-) < adr(+)
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final pr = rand.nextInt(0x10000);
        final op = 0x4000 | (gr << 4);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x10000) | 0x8000;
        final v2 = rand.nextInt(0x8000);

        r.PR = pr;
        r.setGR(gr, v1);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[adr] = v2;

        compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(true));
        expect(r.OF, equals(false));
      }

      // r(+) < adr(+)
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final pr = rand.nextInt(0x10000);
        final op = 0x4000 | (gr << 4);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x4000);
        final v2 = rand.nextInt(0x8000) | 0x4000;

        r.PR = pr;
        r.setGR(gr, v1);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[adr] = v2;

        compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(true));
        expect(r.OF, equals(false));
      }

      // r(-) < adr(-)
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final pr = rand.nextInt(0x10000);
        final op = 0x4000 | (gr << 4);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x100) | 0x8000;
        final v2 = rand.nextInt(0x100) | 0xff00;

        r.PR = pr;
        r.setGR(gr, v1);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[adr] = v2;

        compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(true));
        expect(r.OF, equals(false));
      }
    });

    test('with base r<adr', () {
      final r = Resource();

      // r(-) < adr(+)
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final op = 0x4000 | (gr << 4) | x;
        final pr = rand.nextInt(0x10000);
        final base = rand.nextInt(0x10000);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x10000) | 0x8000;
        final v2 = rand.nextInt(0x8000);

        r.PR = pr;
        r.setGR(gr, v1);
        r.setGR(x, base);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[(base + adr) & 0xffff] = v2;

        compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(true));
        expect(r.OF, equals(false));
      }

      // r(+) < adr(+)
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final op = 0x4000 | (gr << 4) | x;
        final pr = rand.nextInt(0x10000);
        final base = rand.nextInt(0x10000);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x4000);
        final v2 = rand.nextInt(0x8000) | 0x4000;

        r.PR = pr;
        r.setGR(gr, v1);
        r.setGR(x, base);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[(base + adr) & 0xffff] = v2;

        compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(true));
        expect(r.OF, equals(false));
      }

      // r(-) < adr(-)
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final op = 0x4000 | (gr << 4) | x;
        final pr = rand.nextInt(0x10000);
        final base = rand.nextInt(0x10000);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x100) | 0x8000;
        final v2 = rand.nextInt(0x100) | 0xff00;

        r.PR = pr;
        r.setGR(gr, v1);
        r.setGR(x, base);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[(base + adr) & 0xffff] = v2;

        compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(true));
        expect(r.OF, equals(false));
      }
    });
  });

  group('compare arithmetic', () {
    test('r1 > r2', () {
      final r = Resource();

      // r1(+) > r2(-)
      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x4400 | (r1 << 4) | r2;
        final pr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x8000);
        final v2 = rand.nextInt(0x10000) | 0x8000;

        r.PR = pr;
        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory[pr] = op;

        compareArithmetic(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }

      // r1(+) > r2(+)
      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x4400 | (r1 << 4) | r2;
        final pr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x8000) | 0x4400;
        final v2 = rand.nextInt(0x4400);

        r.PR = pr;
        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory[pr] = op;

        compareArithmetic(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }

      // r1(-) > r2(-)
      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x4400 | (r1 << 4) | r2;
        final pr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x100) | 0xff00;
        final v2 = rand.nextInt(0x100) | 0x8000;

        r.PR = pr;
        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory[pr] = op;

        compareArithmetic(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }
    });

    test('r1 = r2', () {
      final r = Resource();

      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x4400 | (r1 << 4) | r2;
        final pr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x10000);
        final v2 = v1;

        r.PR = pr;
        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory[pr] = op;

        compareArithmetic(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.ZF, equals(true));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }
    });

    test('r1 < r2', () {
      final r = Resource();

      // r1(-) < r2(+)
      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x4400 | (r1 << 4) | r2;
        final pr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x10000) | 0x8000;
        final v2 = rand.nextInt(0x8000);

        r.PR = pr;
        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory[pr] = op;

        compareArithmetic(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(true));
        expect(r.OF, equals(false));
      }

      // r1(+) < r2(+)
      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x4400 | (r1 << 4) | r2;
        final pr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x4400);
        final v2 = rand.nextInt(0x8000) | 0x4400;

        r.PR = pr;
        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory[pr] = op;

        compareArithmetic(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(true));
        expect(r.OF, equals(false));
      }

      // r(-) < adr(-)
      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x4400 | (r1 << 4) | r2;
        final pr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x100) | 0x8000;
        final v2 = rand.nextInt(0x100) | 0xff00;

        r.PR = pr;
        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory[pr] = op;

        compareArithmetic(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(true));
        expect(r.OF, equals(false));
      }
    });
  });

  group('compare logical memory', () {
    test('without base r>adr', () {
      final r = Resource();

      // r > adr
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final pr = rand.nextInt(0x10000);
        final op = 0x4100 | (gr << 4);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x10000) | 0x8000;
        final v2 = rand.nextInt(0x8000);

        r.PR = pr;
        r.setGR(gr, v1);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[adr] = v2;

        compareLogicalMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }
    });

    test('with base r>adr', () {
      final r = Resource();

      // r > adr
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final op = 0x4100 | (gr << 4) | x;
        final pr = rand.nextInt(0x10000);
        final base = rand.nextInt(0x10000);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x10000) | 0x8000;
        final v2 = rand.nextInt(0x8000);

        r.PR = pr;
        r.setGR(gr, v1);
        r.setGR(x, base);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[(base + adr) & 0xffff] = v2;

        compareLogicalMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }
    });

    test('without base r=adr', () {
      final r = Resource();

      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final pr = rand.nextInt(0x10000);
        final op = 0x4100 | (gr << 4);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x10000);
        final v2 = v1;

        r.PR = pr;
        r.setGR(gr, v1);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[adr] = v2;

        compareLogicalMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(true));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }
    });

    test('with base r=adr', () {
      final r = Resource();

      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final op = 0x4100 | (gr << 4) | x;
        final pr = rand.nextInt(0x10000);
        final base = rand.nextInt(0x10000);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x10000);
        final v2 = v1;

        r.PR = pr;
        r.setGR(gr, v1);
        r.setGR(x, base);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[(base + adr) & 0xffff] = v2;

        compareLogicalMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(true));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }
    });

    test('without base r<adr', () {
      final r = Resource();

      // r < adr
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final pr = rand.nextInt(0x10000);
        final op = 0x4100 | (gr << 4);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x8000);
        final v2 = rand.nextInt(0x10000) | 0x8000;

        r.PR = pr;
        r.setGR(gr, v1);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[adr] = v2;

        compareLogicalMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(true));
        expect(r.OF, equals(false));
      }
    });

    test('with base r<adr', () {
      final r = Resource();

      // r < adr
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final op = 0x4100 | (gr << 4) | x;
        final pr = rand.nextInt(0x10000);
        final base = rand.nextInt(0x10000);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x8000);
        final v2 = rand.nextInt(0x10000) | 0x8000;

        r.PR = pr;
        r.setGR(gr, v1);
        r.setGR(x, base);
        r.memory[pr] = op;
        r.memory[(pr + 1) & 0xffff] = adr;
        r.memory[(base + adr) & 0xffff] = v2;

        compareLogicalMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(true));
        expect(r.OF, equals(false));
      }
    });
  });

  group('compare logical', () {
    test('r1 > r2', () {
      final r = Resource();

      // r1 > r2
      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x4500 | (r1 << 4) | r2;
        final pr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x10000) | 0x8000;
        final v2 = rand.nextInt(0x8000);

        r.PR = pr;
        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory[pr] = op;

        compareLogical(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }
    });

    test('r1 = r2', () {
      final r = Resource();

      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x4500 | (r1 << 4) | r2;
        final pr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x10000);
        final v2 = v1;

        r.PR = pr;
        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory[pr] = op;

        compareLogical(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.ZF, equals(true));
        expect(r.SF, equals(false));
        expect(r.OF, equals(false));
      }
    });

    test('r1 < r2', () {
      final r = Resource();

      // r1 < r2
      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x4500 | (r1 << 4) | r2;
        final pr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x8000);
        final v2 = rand.nextInt(0x10000) | 0x8000;

        r.PR = pr;
        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory[pr] = op;

        compareLogical(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.ZF, equals(false));
        expect(r.SF, equals(true));
        expect(r.OF, equals(false));
      }
    });
  });
}
