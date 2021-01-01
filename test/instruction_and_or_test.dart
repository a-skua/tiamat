import 'dart:math';

import 'package:tiamat/src/instruction.dart';
import 'package:tiamat/src/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('and', () {
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
  });
}
