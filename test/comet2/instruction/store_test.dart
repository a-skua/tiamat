import 'dart:math';

import 'package:tiamat/src/comet2/instruction/store.dart';
import 'package:tiamat/src/resource/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('store', () {
    final testdata = [
      for (var i = 0; i < 32; i++)
        () {
          final r = rand.nextInt(8);
          return TestData(
            Entity(r, rand.nextInt(0x10000)),
            Entity(getX(r), rand.nextInt(0x10000)),
            adr: Entity(rand.nextInt(0x10000)),
            pr: rand.nextInt(0x10000),
          );
        }(),
    ];

    const operand = 0x1100;
    final r = Resource();
    for (var i = 0; i < testdata.length; i++) {
      test('$i', () {
        final data = testdata[i];
        final op = operand | data.r.value << 4 | data.x.value;

        final pr = r.programRegister;
        final gr = r.generalRegisters;
        final fr = r.flagRegister;

        pr.value = data.pr;
        gr[data.r.value].value = data.r.data;
        gr[data.x.value].value = data.x.data;
        r.memory[data.pr] = op;
        r.memory[data.pr + 1] = data.adr.value;

        final flag = Flag(
          overflow: fr.isOverflow,
          sign: fr.isSign,
          zero: fr.isZero,
        );
        final expectGR = <int>[];
        for (var i = 0; i < 8; i++) {
          expectGR.add(gr[i].value);
        }
        store(r);
        expect(pr.value, equals((data.pr + 2) & 0xffff));
        for (var i = 0; i < 8; i++) {
          expect(gr[i].value, equals(expectGR[i]));
        }
        expect(fr.isOverflow, equals(flag.overflow));
        expect(fr.isSign, equals(flag.sign));
        expect(fr.isZero, equals(flag.zero));
        if (data.x.value > 0) {
          expect(
            r.memory[data.x.data + data.adr.value],
            equals(data.r.data),
          );
        } else {
          expect(
            r.memory[data.adr.value],
            equals(data.r.data),
          );
        }
      });
    }
  });
}
