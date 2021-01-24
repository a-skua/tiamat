import 'dart:math';

import 'package:tiamat/src/comet2/instruction.dart';
import 'package:tiamat/src/comet2/resource.dart';
import 'package:test/test.dart';

import 'util.dart' as util;

void main() {
  final rand = Random();

  group('no operation', () {
    const operand = 0x0000;
    final r = Resource();
    for (var i = 0; i < 8; i++) {
      test('$i', () {
        final pr = r.programRegister;
        final gr = r.generalRegisters;
        final fr = r.flagRegister;

        final adr = rand.nextInt(0x10000);
        pr.value = adr;
        r.memory[adr] = operand;

        final flag = util.Flag(
          overflow: fr.isOverflow,
          sign: fr.isSign,
          zero: fr.isZero,
        );
        final expectGR = <int>[];
        final expectPR = pr.value;
        for (final r in gr) {
          expectGR.add(r.value);
        }
        noOperation(r);
        expect(pr.value, equals((expectPR + 1) & 0xffff));
        for (var i = 0; i < 8; i++) {
          expect(gr[i].value, equals(expectGR[i]));
        }
        expect(fr.isOverflow, equals(flag.overflow));
        expect(fr.isSign, equals(flag.sign));
        expect(fr.isZero, equals(flag.zero));
      });
    }
  });
}
