import 'dart:math';

import 'package:tiamat/src/comet2/instruction/no_operation.dart';
import 'package:tiamat/src/resource/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

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

        final flag = Flag(
          overflow: fr.overflow,
          sign: fr.sign,
          zero: fr.zero,
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
        expect(fr.overflow, equals(flag.overflow));
        expect(fr.sign, equals(flag.sign));
        expect(fr.zero, equals(flag.zero));
      });
    }
  });
}
