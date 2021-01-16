import 'dart:math';

import 'package:tiamat/src/comet2/instruction/instruction.dart';
import 'package:tiamat/src/resource/resource.dart';
import 'package:test/test.dart';

import '../../util/util.dart';

void main() {
  final rand = Random();

  group('push', () {
    test('push GR', () {
      final r = Resource();

      for (var i = 1; i < 8; i++) {
        final v = rand.nextInt(0x10000);
        final op = 0x7000 | i;
        final adr = 0;
        final sp = r.SP;
        final pr = r.PR;

        r.setGR(i, v);
        r.memory[r.PR] = op;
        r.memory[r.PR + 1] = adr;

        push(r);
        expect(r.SP, equals(sp - 1));
        expect(r.PR, equals(pr + 2));
        expect(r.memory[r.SP], equals(v));
      }
    });

    test('push address', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final op = 0x7000;
        final adr = rand.nextInt(0x10000);
        final sp = r.SP;
        final pr = r.PR;

        r.memory[r.PR] = op;
        r.memory[r.PR + 1] = adr;

        push(r);
        expect(r.SP, equals(sp - 1));
        expect(r.PR, equals(pr + 2));
        expect(r.memory[r.SP], equals(adr));
      }
    });

    test('default', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final x = getX(0);
        final op = 0x7000 | x;
        final base = rand.nextInt(0x8000);
        final adr = rand.nextInt(0x8000);
        final sp = r.SP;
        final pr = r.PR;

        r.setGR(x, base);
        r.memory[r.PR] = op;
        r.memory[r.PR + 1] = adr;

        push(r);
        expect(r.SP, equals(sp - 1));
        expect(r.PR, equals(pr + 2));
        expect(r.memory[r.SP], equals(base + adr));
      }
    });
  });

  group('pop', () {
    test('default', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final gr = rand.nextInt(8);
        final op = 0x7100 | (gr << 4);
        final v = rand.nextInt(0x10000);
        final sp = r.SP;
        final pr = r.PR + 1;

        r.SP -= 1;
        r.memory[r.SP] = v;
        r.memory[r.PR] = op;

        pop(r);
        expect(r.SP, equals(sp));
        expect(r.PR, equals(pr));
        expect(r.getGR(gr), equals(v));
      }
    });
  });
}
