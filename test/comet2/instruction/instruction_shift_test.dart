import 'dart:math';

import 'package:tiamat/src/comet2/instruction/instruction.dart';
import 'package:tiamat/src/resource/resource.dart';
import 'package:test/test.dart';

import '../../util/util.dart';

void main() {
  final rand = Random();

  group('shift left arithmetic', () {
    test('without base', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final gr = rand.nextInt(8);
        final v = rand.nextInt(0x10000);
        final op = 0x5000 | (gr << 4);
        final adr = rand.nextInt(0xf) + 1;
        final pr = r.PR;

        r.setGR(gr, v);
        r.memory[pr] = op;
        r.memory[pr + 1] = adr;

        shiftLeftArithmetic(r);
        final result = (v << adr) & 0xffff;
        final sf = (result & 0x8000) > 0;
        final zf = result == 0;
        final of = (((v << (adr - 1)) >> (wordSize - 1)) & 1) > 0;

        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.SF, equals(sf));
        expect(r.ZF, equals(zf));
        expect(r.OF, equals(of));
      }
    });

    test('with base', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final v = rand.nextInt(0x10000);
        final op = 0x5000 | (gr << 4) | x;
        final base = rand.nextInt(8);
        final adr = rand.nextInt(8) + 1;
        final pr = r.PR;

        r.setGR(gr, v);
        r.setGR(x, base);
        r.memory[pr] = op;
        r.memory[pr + 1] = adr;

        shiftLeftArithmetic(r);
        final result = (v << (base + adr)) & 0xffff;
        final sf = (result & 0x8000) > 0;
        final zf = result == 0;
        final of = (((v << ((base + adr) - 1)) >> (wordSize - 1)) & 1) > 0;

        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.SF, equals(sf));
        expect(r.ZF, equals(zf));
        expect(r.OF, equals(of));
      }
    });
  });

  group('shift right arithmetic', () {
    test('without base', () {
      final r = Resource();

      // +
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final v = rand.nextInt(0x8000);
        final op = 0x5100 | (gr << 4);
        final adr = rand.nextInt(0xf) + 1;
        final pr = r.PR;

        r.setGR(gr, v);
        r.memory[pr] = op;
        r.memory[pr + 1] = adr;

        shiftRightArithmetic(r);
        final result = (v >> adr) & 0xffff;
        final sf = (result & 0x8000) > 0;
        final zf = result == 0;
        final of = ((v >> (adr - 1)) & 1) > 0;

        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.SF, equals(sf));
        expect(r.ZF, equals(zf));
        expect(r.OF, equals(of));
      }

      // -
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final v = -(rand.nextInt(0x8000) + 1);
        final op = 0x5100 | (gr << 4);
        final adr = rand.nextInt(0xf) + 1;
        final pr = r.PR;

        r.setGR(gr, v);
        r.memory[pr] = op;
        r.memory[pr + 1] = adr;

        expect(r.getGR(gr), equals(v & 0xffff));
        shiftRightArithmetic(r);
        final result = (v >> adr) & 0xffff;
        final zf = result == 0;
        final of = ((v >> (adr - 1)) & 1) > 0;

        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.SF, equals(true));
        expect(r.ZF, equals(zf));
        expect(r.OF, equals(of));
      }
    });

    test('with base', () {
      final r = Resource();

      // +
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final v = rand.nextInt(0x8000);
        final op = 0x5100 | (gr << 4) | x;
        final base = rand.nextInt(8);
        final adr = rand.nextInt(8) + 1;
        final pr = r.PR;

        r.setGR(gr, v);
        r.setGR(x, base);
        r.memory[pr] = op;
        r.memory[pr + 1] = adr;

        shiftRightArithmetic(r);
        final result = (v >> (base + adr)) & 0xffff;
        final sf = (result & 0x8000) > 0;
        final zf = result == 0;
        final of = ((v >> ((base + adr) - 1)) & 1) > 0;

        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.SF, equals(sf));
        expect(r.ZF, equals(zf));
        expect(r.OF, equals(of));
      }

      // -
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final v = -(rand.nextInt(0x8000) + 1);
        final op = 0x5100 | (gr << 4) | x;
        final base = rand.nextInt(8);
        final adr = rand.nextInt(8) + 1;
        final pr = r.PR;

        r.setGR(gr, v);
        r.setGR(x, base);
        r.memory[pr] = op;
        r.memory[pr + 1] = adr;

        expect(r.getGR(gr), equals(v & 0xffff));
        shiftRightArithmetic(r);
        final result = (v >> (base + adr)) & 0xffff;
        final sf = (result & 0x8000) > 0;
        final zf = result == 0;
        final of = ((v >> ((base + adr) - 1)) & 1) > 0;

        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.SF, equals(true));
        expect(r.ZF, equals(zf));
        expect(r.OF, equals(of));
      }
    });
  });

  group('shift left logical', () {
    test('without base', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final gr = rand.nextInt(8);
        final v = rand.nextInt(0x10000);
        final op = 0x5200 | (gr << 4);
        final adr = rand.nextInt(0xf) + 1;
        final pr = r.PR;

        r.setGR(gr, v);
        r.memory[pr] = op;
        r.memory[pr + 1] = adr;

        shiftLeftLogical(r);
        final result = (v << adr) & 0xffff;
        final sf = (result & 0x8000) > 0;
        final zf = result == 0;
        final of = (((v << (adr - 1)) >> (wordSize - 1)) & 1) > 0;

        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.SF, equals(sf));
        expect(r.ZF, equals(zf));
        expect(r.OF, equals(of));
      }
    });

    test('with base', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final v = rand.nextInt(0x10000);
        final op = 0x5200 | (gr << 4) | x;
        final base = rand.nextInt(8);
        final adr = rand.nextInt(8) + 1;
        final pr = r.PR;

        r.setGR(gr, v);
        r.setGR(x, base);
        r.memory[pr] = op;
        r.memory[pr + 1] = adr;

        shiftLeftLogical(r);
        final result = (v << (base + adr)) & 0xffff;
        final sf = (result & 0x8000) > 0;
        final zf = result == 0;
        final of = (((v << ((base + adr) - 1)) >> (wordSize - 1)) & 1) > 0;

        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.SF, equals(sf));
        expect(r.ZF, equals(zf));
        expect(r.OF, equals(of));
      }
    });
  });

  group('shift right logical', () {
    test('without base', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final gr = rand.nextInt(8);
        final v = rand.nextInt(0x10000);
        final op = 0x5300 | (gr << 4);
        final adr = rand.nextInt(0xf) + 1;
        final pr = r.PR;

        r.setGR(gr, v);
        r.memory[pr] = op;
        r.memory[pr + 1] = adr;

        shiftRightLogical(r);
        final result = (v >> adr) & 0xffff;
        final sf = (result & 0x8000) > 0;
        final zf = result == 0;
        final of = ((v >> (adr - 1)) & 1) > 0;

        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.SF, equals(sf));
        expect(r.ZF, equals(zf));
        expect(r.OF, equals(of));
      }
    });

    test('with base', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final v = rand.nextInt(0x10000);
        final op = 0x5300 | (gr << 4) | x;
        final base = rand.nextInt(8);
        final adr = rand.nextInt(8) + 1;
        final pr = r.PR;

        r.setGR(gr, v);
        r.setGR(x, base);
        r.memory[pr] = op;
        r.memory[pr + 1] = adr;

        shiftRightLogical(r);
        final result = (v >> (base + adr)) & 0xffff;
        final sf = (result & 0x8000) > 0;
        final zf = result == 0;
        final of = ((v >> ((base + adr) - 1)) & 1) > 0;

        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.SF, equals(sf));
        expect(r.ZF, equals(zf));
        expect(r.OF, equals(of));
      }
    });
  });
}
