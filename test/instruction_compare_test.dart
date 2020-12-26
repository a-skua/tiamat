import 'dart:math';

import 'package:tiamat/src/instruction.dart';
import 'package:tiamat/src/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('compare arithmetic memory', () {
    test('without base r>adr', () {
      final r = Resource();
      final ins = Instruction();

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
        r.memory.setWord(pr, op);
        r.memory.setWord((pr + 1) & 0xffff, adr);
        r.memory.setWord(adr, v2);

        ins.compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.FR, equals(0));
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
        r.memory.setWord(pr, op);
        r.memory.setWord((pr + 1) & 0xffff, adr);
        r.memory.setWord(adr, v2);

        ins.compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.FR, equals(0));
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
        r.memory.setWord(pr, op);
        r.memory.setWord((pr + 1) & 0xffff, adr);
        r.memory.setWord(adr, v2);

        ins.compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.FR, equals(0));
      }
    });

    test('with base r>adr', () {
      final r = Resource();
      final ins = Instruction();

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
        r.memory.setWord(pr, op);
        r.memory.setWord((pr + 1) & 0xffff, adr);
        r.memory.setWord((base + adr) & 0xffff, v2);

        ins.compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.FR, equals(0));
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
        r.memory.setWord(pr, op);
        r.memory.setWord((pr + 1) & 0xffff, adr);
        r.memory.setWord((base + adr) & 0xffff, v2);

        ins.compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.FR, equals(0));
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
        r.memory.setWord(pr, op);
        r.memory.setWord((pr + 1) & 0xffff, adr);
        r.memory.setWord((base + adr) & 0xffff, v2);

        ins.compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.FR, equals(0));
      }
    });

    test('without base r=adr', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final pr = rand.nextInt(0x10000);
        final op = 0x4000 | (gr << 4);
        final adr = rand.nextInt(0x10000);
        final v1 = rand.nextInt(0x10000);
        final v2 = v1;

        r.PR = pr;
        r.setGR(gr, v1);
        r.memory.setWord(pr, op);
        r.memory.setWord((pr + 1) & 0xffff, adr);
        r.memory.setWord(adr, v2);

        ins.compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.FR, equals(1));
      }
    });

    test('with base r=adr', () {
      final r = Resource();
      final ins = Instruction();

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
        r.memory.setWord(pr, op);
        r.memory.setWord((pr + 1) & 0xffff, adr);
        r.memory.setWord((base + adr) & 0xffff, v2);

        ins.compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.FR, equals(1));
      }
    });

    test('without base r<adr', () {
      final r = Resource();
      final ins = Instruction();

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
        r.memory.setWord(pr, op);
        r.memory.setWord((pr + 1) & 0xffff, adr);
        r.memory.setWord(adr, v2);

        ins.compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.FR, equals(2));
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
        r.memory.setWord(pr, op);
        r.memory.setWord((pr + 1) & 0xffff, adr);
        r.memory.setWord(adr, v2);

        ins.compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.FR, equals(2));
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
        r.memory.setWord(pr, op);
        r.memory.setWord((pr + 1) & 0xffff, adr);
        r.memory.setWord(adr, v2);

        ins.compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.FR, equals(2));
      }
    });

    test('with base r<adr', () {
      final r = Resource();
      final ins = Instruction();

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
        r.memory.setWord(pr, op);
        r.memory.setWord((pr + 1) & 0xffff, adr);
        r.memory.setWord((base + adr) & 0xffff, v2);

        ins.compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.FR, equals(2));
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
        r.memory.setWord(pr, op);
        r.memory.setWord((pr + 1) & 0xffff, adr);
        r.memory.setWord((base + adr) & 0xffff, v2);

        ins.compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.FR, equals(2));
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
        r.memory.setWord(pr, op);
        r.memory.setWord((pr + 1) & 0xffff, adr);
        r.memory.setWord((base + adr) & 0xffff, v2);

        ins.compareArithmeticMemory(r);
        expect(r.PR, equals((pr + 2) & 0xffff));
        expect(r.FR, equals(2));
      }
    });
  });

  group('compare arithmetic', () {
    test('r1 > r2', () {
      final r = Resource();
      final ins = Instruction();

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
        r.memory.setWord(pr, op);

        ins.compareArithmetic(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.FR, equals(0));
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
        r.memory.setWord(pr, op);

        ins.compareArithmetic(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.FR, equals(0));
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
        r.memory.setWord(pr, op);

        ins.compareArithmetic(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.FR, equals(0));
      }
    });

    test('r1 = r2', () {
      final r = Resource();
      final ins = Instruction();

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
        r.memory.setWord(pr, op);

        ins.compareArithmetic(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.FR, equals(1));
      }
    });

    test('r1 < r2', () {
      final r = Resource();
      final ins = Instruction();

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
        r.memory.setWord(pr, op);

        ins.compareArithmetic(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.FR, equals(2));
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
        r.memory.setWord(pr, op);

        ins.compareArithmetic(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.FR, equals(2));
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
        r.memory.setWord(pr, op);

        ins.compareArithmetic(r);
        expect(r.PR, equals((pr + 1) & 0xffff));
        expect(r.FR, equals(2));
      }
    });
  });
}
