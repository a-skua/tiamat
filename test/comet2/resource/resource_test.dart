import 'dart:math';

import 'package:tiamat/src/comet2/resource.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  const generalRegisterSize = 8;
  const wordSize = 0x10000;
  const randSize = 0x10000;
  group('GRs', () {
    for (var i = 0; i < generalRegisterSize; i++) {
      test('set/get success; GR[$i]', () {
        final r = Resource();
        final val = rand.nextInt(randSize);
        expect(r.setGR(i, val), equals(true));
        expect(r.getGR(i), equals(val));
      });
    }
  });

  group('SP', () {
    test('set/get SP boundary', () {
      final r = Resource();
      r.SP = 1 << 16;
      expect(r.SP, equals(0));

      final val = rand.nextInt(1 << 16);
      r.SP = (1 << 16) + val;
      expect(r.SP, equals(val));

      r.SP = -1;
      expect(r.SP, equals((1 << 16) - 1));
    });

    for (var i = 0; i < 8; i++) {
      test('set/get SP', () {
        final r = Resource();
        final val = rand.nextInt(1 << 16);
        r.SP = val;
        expect(r.SP, equals(val));
      });
    }
  });

  group('PR', () {
    test('set/get PR boundary', () {
      final r = Resource();
      r.PR = 1 << 16;
      expect(r.PR, equals(0));

      final val = rand.nextInt(1 << 16);
      r.PR = (1 << 16) + val;
      expect(r.PR, equals(val));

      r.PR = -1;
      expect(r.PR, equals((1 << 16) - 1));
    });

    for (var i = 0; i < 8; i++) {
      test('set/get PR', () {
        final r = Resource();
        final val = rand.nextInt(1 << 16);
        r.PR = val;
        expect(r.PR, equals(val));
      });
    }
  });

  group('FR', () {
    test('set/get FR boundary', () {
      final r = Resource();
      r.FR = 1 << 3;
      expect(r.FR, equals(0));

      final val = rand.nextInt(1 << 3);
      r.FR = (1 << 3) + val;
      expect(r.FR, equals(val));

      r.FR = -1;
      expect(r.FR, equals((1 << 3) - 1));
    });

    for (var i = 0; i < 4; i++) {
      test('set/get FR', () {
        final r = Resource();
        final val = rand.nextInt(1 << 3);
        r.FR = val;
        expect(r.FR, equals(val));
      });
    }

    for (var i = 0; i < 1 << 3; i++) {
      test('set/get flags', () {
        final r = Resource();
        int val = 0;
        bool of = false;
        bool sf = false;
        bool zf = false;

        if (i & Flag.overflow > 0) {
          of = true;
          val |= Flag.overflow;
        }
        if (i & Flag.sign > 0) {
          sf = true;
          val |= Flag.sign;
        }
        if (i & Flag.zero > 0) {
          zf = true;
          val |= Flag.zero;
        }
        r.OF = of;
        r.SF = sf;
        r.ZF = zf;

        expect(r.OF, equals(of));
        expect(r.SF, equals(sf));
        expect(r.ZF, equals(zf));
        expect(r.FR, equals(val));
      });
    }
  });

  test('memory', () {
    final r = Resource();
    for (var i = 0; i < 8; i++) {
      final addr = rand.nextInt(r.memory.length);
      final val = rand.nextInt(wordSize);
      r.memory[addr] = val;
      expect(r.memory[addr], equals(val));
    }
  });
}
