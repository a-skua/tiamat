import 'dart:math';

import 'package:tiamat/src/instruction.dart';
import 'package:tiamat/src/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('unconditional jump', () {
    test('without base', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 4; i++) {
        final op = 0x6400;
        final adr = rand.nextInt(0x10000);

        r.memory.setWord(r.PR, op);
        r.memory.setWord(r.PR + 1, adr);

        ins.unconditionalJump(r);
        expect(r.PR, equals(adr));
      }
    });

    test('with base', () {
      final r = Resource();
      final ins = Instruction();
      for (var i = 0; i < 4; i++) {
        final baseGR = getX(0);
        final op = 0x6400 | baseGR;
        final base = rand.nextInt(0x8000);
        final adr = rand.nextInt(0x8000);

        r.setGR(baseGR, base);
        r.memory.setWord(r.PR, op);
        r.memory.setWord(r.PR + 1, adr);

        ins.unconditionalJump(r);
        expect(r.PR, equals(base + adr));
      }
    });
  });
}
