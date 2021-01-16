import 'dart:math';

import 'package:tiamat/src/comet2/instruction/load.dart';
import 'package:tiamat/src/resource/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('load', () {
    group('r1,r2', () {
      final testdata = [
        TestData(
          Entity(rand.nextInt(8), 0),
          Entity(rand.nextInt(8), 0),
        ),
        TestData(
          Entity(rand.nextInt(8), 0),
          Entity(rand.nextInt(8), 0x8000),
        ),
        TestData(
          Entity(rand.nextInt(8), 0),
          Entity(rand.nextInt(8), rand.nextInt(0x10000)),
          pr: 0xffff,
        ),
        for (var i = 0; i < 24; i++)
          TestData(
            Entity(rand.nextInt(8), 0),
            Entity(rand.nextInt(8), rand.nextInt(0x10000)),
            pr: rand.nextInt(0x10000),
          ),
      ];

      const operand = 0x1400;
      final r = Resource();
      for (var i = 0; i < testdata.length; i++) {
        final d = testdata[i];
        test('$i', () {
          final op = operand | d.r1.value << 4 | d.r2.value;

          r.PR = d.pr;
          r.setGR(d.r2.value, d.r2.data);
          r.memory.setWord(d.pr, op);

          final gr = <int>[];
          for (var i = 0; i < 8; i++) {
            if (i == d.r1.value) {
              gr.add(d.r2.data);
            } else {
              gr.add(r.getGR(i));
            }
          }
          loadGR(r);
          expect(r.PR, equals((d.pr + 1) & 0xffff));
          for (var i = 0; i < 8; i++) {
            expect(r.getGR(i), equals(gr[i]));
          }
          expect(r.OF, equals(false));
          expect(r.ZF, equals(r.getGR(d.r1.value) == 0));
          expect(r.SF, equals((r.getGR(d.r1.value) & 0x8000) > 0));
        });
      }
    });

    group('r,adr,x', () {
      final testdata = [
        TestData(
          Entity(rand.nextInt(8), 0),
          Entity(rand.nextInt(8), rand.nextInt(0x10000)),
          adr: Entity(rand.nextInt(0x4000) | 0x8000, 0),
        ),
        TestData(
          Entity(rand.nextInt(8), 0),
          Entity(rand.nextInt(8), rand.nextInt(0x4000)),
          adr: Entity(rand.nextInt(0x4000) | 0x8000, 0x8000),
        ),
        for (var i = 0; i < 24; i++)
          TestData(
            Entity(rand.nextInt(8), 0),
            Entity(rand.nextInt(8), rand.nextInt(0x4000)),
            adr: Entity(rand.nextInt(0x4000) | 0x8000, rand.nextInt(0x10000)),
          ),
      ];

      const operand = 0x10000;
      final r = Resource();
      for (var i = 0; i < testdata.length; i++) {
        final d = testdata[i];
        test('$i', () {
          final op = operand | d.r.value << 4 | d.x.value;

          r.PR = d.pr;
          if (d.x.value > 0) {
            r.setGR(d.x.value, d.x.data);
            r.memory.setWord(d.x.data + d.adr.value, d.adr.data);
          } else {
            r.memory.setWord(d.adr.value, d.adr.data);
          }
          r.memory.setWord(d.pr, op);
          r.memory.setWord(d.pr + 1, d.adr.value);

          final gr = <int>[];
          for (var i = 0; i < 8; i++) {
            if (i == d.r.value) {
              gr.add(d.adr.data);
            } else {
              gr.add(r.getGR(i));
            }
          }
          load(r);
          expect(r.PR, equals((d.pr + 2) & 0xffff));
          for (var i = 0; i < 8; i++) {
            expect(r.getGR(i), equals(gr[i]));
          }
          expect(r.OF, equals(false));
          expect(r.ZF, equals(r.getGR(d.r.value) == 0));
          expect(r.SF, equals((r.getGR(d.r.value) & 0x8000) > 0));
        });
      }
    });
  });
}
