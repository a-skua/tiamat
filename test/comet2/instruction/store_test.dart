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
      final d = testdata[i];
      test('$i', () {
        final op = operand | d.r.value << 4 | d.x.value;

        r.PR = d.pr;
        r.setGR(d.r.value, d.r.data);
        r.setGR(d.x.value, d.x.data);
        r.memory.setWord(d.pr, op);
        r.memory.setWord(d.pr + 1, d.adr.value);

        final flag = Flag(
          overflow: r.OF,
          sign: r.SF,
          zero: r.ZF,
        );
        final gr = <int>[];
        for (var i = 0; i < 8; i++) {
          gr.add(r.getGR(i));
        }
        store(r);
        expect(r.PR, equals((d.pr + 2) & 0xffff));
        for (var i = 0; i < 8; i++) {
          expect(r.getGR(i), equals(gr[i]));
        }
        expect(r.OF, equals(flag.overflow));
        expect(r.SF, equals(flag.sign));
        expect(r.ZF, equals(flag.zero));
        if (d.x.value > 0) {
          expect(
            r.memory.getWord(d.x.data + d.adr.value),
            equals(d.r.data),
          );
        } else {
          expect(
            r.memory.getWord(d.adr.value),
            equals(d.r.data),
          );
        }
      });
    }
  });
}
