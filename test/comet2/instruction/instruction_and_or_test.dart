import 'dart:math';

import 'package:tiamat/src/comet2/instruction/instruction.dart';
import 'package:tiamat/src/resource/resource.dart';
import 'package:test/test.dart';

import '../../util/util.dart';

void main() {
  final rand = Random();

  group('and memory', () {
    test('without base', () {
      final r = Resource();

      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final op = 0x3000 | (gr << 4);
        final adr = rand.nextInt(0x10000) | 0x8000;
        final v1 = rand.nextInt(0x10000);
        final v2 = rand.nextInt(0x10000);
        final result = v1 & v2;
        final pr = r.PR;

        r.setGR(gr, v1);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, adr);
        r.memory.setWord(adr, v2);

        andMemory(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals((result & 0x8000) > 0));
        expect(r.ZF, equals(result == 0));
      }
    });

    test('with base', () {
      final r = Resource();
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final op = 0x3000 | (gr << 4) | x;
        final base = rand.nextInt(0x8000) | 0x4000;
        final adr = rand.nextInt(0x8000) | 0x4000;
        final v1 = rand.nextInt(0x10000);
        final v2 = rand.nextInt(0x10000);
        final result = v1 & v2;
        final pr = r.PR;

        r.setGR(gr, v1);
        r.setGR(x, base);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, adr);
        r.memory.setWord(base + adr, v2);

        andMemory(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals((result & 0x8000) > 0));
        expect(r.ZF, equals(result == 0));
      }
    });

    test('sign flag', () {
      final r = Resource();
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final op = 0x3000 | (gr << 4);
        final adr = rand.nextInt(0x10000) | 0x8000;
        final v1 = rand.nextInt(0x10000) | 0x8000;
        final v2 = rand.nextInt(0x10000) | 0x8000;
        final result = v1 & v2;
        final pr = r.PR;

        r.setGR(gr, v1);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, adr);
        r.memory.setWord(adr, v2);

        andMemory(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals(true));
        expect(r.ZF, equals(false));
      }
    });

    test('zero flag', () {
      final r = Resource();
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final op = 0x3000 | (gr << 4);
        final adr = rand.nextInt(0x10000) | 0x8000;
        final v1 = rand.nextInt(0x10000);
        final v2 = v1 ^ -1;
        final result = 0;
        final pr = r.PR;

        r.setGR(gr, v1);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, adr);
        r.memory.setWord(adr, v2);

        andMemory(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals(false));
        expect(r.ZF, equals(true));
      }
    });
  });

  group('and', () {
    test('default', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x3400 | (r1 << 4) | r2;
        final v1 = rand.nextInt(0x10000);
        final v2 = rand.nextInt(0x10000);
        final result = v1 & v2;
        final pr = r.PR;

        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory.setWord(pr, op);

        and(r);
        expect(r.PR, equals(pr + 1));
        expect(r.getGR(r1), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals((result & 0x8000) > 0));
        expect(r.ZF, equals(result == 0));
      }
    });

    test('sign flag', () {
      final r = Resource();

      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x3400 | (r1 << 4) | r2;
        final v1 = rand.nextInt(0x10000) | 0x8000;
        final v2 = rand.nextInt(0x10000) | 0x8000;
        final result = v1 & v2;
        final pr = r.PR;

        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory.setWord(pr, op);

        and(r);
        expect(r.PR, equals(pr + 1));
        expect(r.getGR(r1), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals(true));
        expect(r.ZF, equals(false));
      }
    });

    test('zero flag', () {
      final r = Resource();

      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x3400 | (r1 << 4) | r2;
        final v1 = rand.nextInt(0x10000);
        final v2 = v1 ^ -1;
        final pr = r.PR;

        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory.setWord(pr, op);

        and(r);
        expect(r.PR, equals(pr + 1));
        expect(r.getGR(r1), equals(0));
        expect(r.OF, equals(false));
        expect(r.SF, equals(false));
        expect(r.ZF, equals(true));
      }
    });
  });

  group('or memory', () {
    test('without base', () {
      final r = Resource();

      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final op = 0x3100 | (gr << 4);
        final adr = rand.nextInt(0x10000) | 0x8000;
        final v1 = rand.nextInt(0x10000);
        final v2 = rand.nextInt(0x10000);
        final result = v1 | v2;
        final pr = r.PR;

        r.setGR(gr, v1);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, adr);
        r.memory.setWord(adr, v2);

        orMemory(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals((result & 0x8000) > 0));
        expect(r.ZF, equals(result == 0));
      }
    });

    test('with base', () {
      final r = Resource();
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final op = 0x3100 | (gr << 4) | x;
        final base = rand.nextInt(0x8000) | 0x4000;
        final adr = rand.nextInt(0x8000) | 0x4000;
        final v1 = rand.nextInt(0x10000);
        final v2 = rand.nextInt(0x10000);
        final result = v1 | v2;
        final pr = r.PR;

        r.setGR(gr, v1);
        r.setGR(x, base);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, adr);
        r.memory.setWord(base + adr, v2);

        orMemory(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals((result & 0x8000) > 0));
        expect(r.ZF, equals(result == 0));
      }
    });

    test('sign flag', () {
      final r = Resource();
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final op = 0x3100 | (gr << 4);
        final adr = rand.nextInt(0x10000) | 0x8000;
        final v1 = rand.nextInt(0x10000) | 0x8000;
        final v2 = rand.nextInt(0x10000);
        final result = v1 | v2;
        final pr = r.PR;

        r.setGR(gr, v1);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, adr);
        r.memory.setWord(adr, v2);

        orMemory(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals(true));
        expect(r.ZF, equals(false));
      }
    });

    test('zero flag', () {
      final r = Resource();
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final op = 0x3100 | (gr << 4);
        final adr = rand.nextInt(0x10000) | 0x8000;
        final v1 = 0;
        final v2 = 0;
        final pr = r.PR;

        r.setGR(gr, v1);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, adr);
        r.memory.setWord(adr, v2);

        orMemory(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(0));
        expect(r.OF, equals(false));
        expect(r.SF, equals(false));
        expect(r.ZF, equals(true));
      }
    });
  });

  group('or', () {
    test('default', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x3500 | (r1 << 4) | r2;
        final v1 = rand.nextInt(0x10000);
        final v2 = rand.nextInt(0x10000);
        final result = v1 | v2;
        final pr = r.PR;

        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory.setWord(pr, op);

        or(r);
        expect(r.PR, equals(pr + 1));
        expect(r.getGR(r1), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals((result & 0x8000) > 0));
        expect(r.ZF, equals(result == 0));
      }
    });

    test('sign flag', () {
      final r = Resource();

      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x3500 | (r1 << 4) | r2;
        final v1 = rand.nextInt(0x10000) | 0x8000;
        final v2 = rand.nextInt(0x10000);
        final result = v1 | v2;
        final pr = r.PR;

        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory.setWord(pr, op);

        or(r);
        expect(r.PR, equals(pr + 1));
        expect(r.getGR(r1), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals(true));
        expect(r.ZF, equals(false));
      }
    });

    test('zero flag', () {
      final r = Resource();

      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x3500 | (r1 << 4) | r2;
        final v1 = 0;
        final v2 = 0;
        final pr = r.PR;

        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory.setWord(pr, op);

        or(r);
        expect(r.PR, equals(pr + 1));
        expect(r.getGR(r1), equals(0));
        expect(r.OF, equals(false));
        expect(r.SF, equals(false));
        expect(r.ZF, equals(true));
      }
    });
  });

  group('exclusive or memory', () {
    test('without base', () {
      final r = Resource();

      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final op = 0x3200 | (gr << 4);
        final adr = rand.nextInt(0x10000) | 0x8000;
        final v1 = rand.nextInt(0x10000);
        final v2 = rand.nextInt(0x10000);
        final result = v1 ^ v2;
        final pr = r.PR;

        r.setGR(gr, v1);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, adr);
        r.memory.setWord(adr, v2);

        exclusiveOrMemory(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals((result & 0x8000) > 0));
        expect(r.ZF, equals(result == 0));
      }
    });

    test('with base', () {
      final r = Resource();
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final x = getX(gr);
        final op = 0x3200 | (gr << 4) | x;
        final base = rand.nextInt(0x8000) | 0x4000;
        final adr = rand.nextInt(0x8000) | 0x4000;
        final v1 = rand.nextInt(0x10000);
        final v2 = rand.nextInt(0x10000);
        final result = (v1 ^ v2) & 0xffff;
        final pr = r.PR;

        r.setGR(gr, v1);
        r.setGR(x, base);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, adr);
        r.memory.setWord(base + adr, v2);

        exclusiveOrMemory(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals((result & 0x8000) > 0));
        expect(r.ZF, equals(result == 0));
      }
    });

    test('sign flag', () {
      final r = Resource();
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final op = 0x3200 | (gr << 4);
        final adr = rand.nextInt(0x10000) | 0x8000;
        final v1 = rand.nextInt(0x10000) | 0x8000;
        final v2 = rand.nextInt(0x8000);
        final result = (v1 ^ v2) & 0xffff;
        final pr = r.PR;

        r.setGR(gr, v1);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, adr);
        r.memory.setWord(adr, v2);

        exclusiveOrMemory(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals(true));
        expect(r.ZF, equals(false));
      }
    });

    test('zero flag', () {
      final r = Resource();
      for (var i = 0; i < 4; i++) {
        final gr = rand.nextInt(8);
        final op = 0x3200 | (gr << 4);
        final adr = rand.nextInt(0x10000) | 0x8000;
        final v1 = rand.nextInt(0x10000);
        final v2 = v1;
        final pr = r.PR;

        r.setGR(gr, v1);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, adr);
        r.memory.setWord(adr, v2);

        exclusiveOrMemory(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(gr), equals(0));
        expect(r.OF, equals(false));
        expect(r.SF, equals(false));
        expect(r.ZF, equals(true));
      }
    });
  });

  group('exclusive or', () {
    test('default', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x3600 | (r1 << 4) | r2;
        final v1 = rand.nextInt(0x10000);
        final v2 = rand.nextInt(0x10000);
        final result = (v1 ^ v2) & 0xffff;
        final pr = r.PR;

        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory.setWord(pr, op);

        exclusiveOr(r);
        expect(r.PR, equals(pr + 1));
        expect(r.getGR(r1), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals((result & 0x8000) > 0));
        expect(r.ZF, equals(result == 0));
      }
    });

    test('sign flag', () {
      final r = Resource();

      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x3600 | (r1 << 4) | r2;
        final v1 = rand.nextInt(0x10000) | 0x8000;
        final v2 = rand.nextInt(0x8000);
        final result = (v1 ^ v2) & 0xffff;
        final pr = r.PR;

        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory.setWord(pr, op);

        exclusiveOr(r);
        expect(r.PR, equals(pr + 1));
        expect(r.getGR(r1), equals(result));
        expect(r.OF, equals(false));
        expect(r.SF, equals(true));
        expect(r.ZF, equals(false));
      }
    });

    test('zero flag', () {
      final r = Resource();

      for (var i = 0; i < 4; i++) {
        final r1 = rand.nextInt(8);
        final r2 = getX(r1, base: 0);
        final op = 0x3600 | (r1 << 4) | r2;
        final v1 = rand.nextInt(0x10000);
        final v2 = v1;
        final pr = r.PR;

        r.setGR(r1, v1);
        r.setGR(r2, v2);
        r.memory.setWord(pr, op);

        exclusiveOr(r);
        expect(r.PR, equals(pr + 1));
        expect(r.getGR(r1), equals(0));
        expect(r.OF, equals(false));
        expect(r.SF, equals(false));
        expect(r.ZF, equals(true));
      }
    });
  });
}
