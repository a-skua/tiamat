import 'dart:math';

import 'package:tiamat/src/comet2/instruction/instruction.dart';
import 'package:tiamat/src/comet2/resource.dart';
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
        test('$i', () {
          final data = testdata[i];
          final op = operand | data.r1.value << 4 | data.r2.value;

          final pr = r.programRegister;
          final gr = r.generalRegisters;
          final fr = r.flagRegister;

          pr.value = data.pr;
          gr[data.r2.value].value = data.r2.data;
          r.memory[data.pr] = op;

          final expectGR = <int>[];
          for (var i = 0; i < 8; i++) {
            if (i == data.r1.value) {
              expectGR.add(data.r2.data);
            } else {
              expectGR.add(gr[i].value);
            }
          }
          loadGR(r);
          expect(pr.value, equals((data.pr + 1) & 0xffff));
          for (var i = 0; i < 8; i++) {
            expect(gr[i].value, equals(expectGR[i]));
          }
          expect(fr.isOverflow, equals(false));
          expect(fr.isSign, equals((gr[data.r1.value].value & 0x8000) > 0));
          expect(fr.isZero, equals(gr[data.r1.value].value == 0));
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
            pr: rand.nextInt(0x7fff),
          ),
      ];

      const operand = 0x10000;
      final r = Resource();
      for (var i = 0; i < testdata.length; i++) {
        test('$i', () {
          final data = testdata[i];
          final op = operand | data.r.value << 4 | data.x.value;

          final pr = r.programRegister;
          final gr = r.generalRegisters;
          final fr = r.flagRegister;

          pr.value = data.pr;
          if (data.x.value > 0) {
            gr[data.x.value].value = data.x.data;
            r.memory[data.x.data + data.adr.value] = data.adr.data;
          } else {
            r.memory[data.adr.value] = data.adr.data;
          }
          r.memory[data.pr] = op;
          r.memory[data.pr + 1] = data.adr.value;

          final expectGR = <int>[];
          for (var i = 0; i < 8; i++) {
            if (i == data.r.value) {
              expectGR.add(data.adr.data);
            } else {
              expectGR.add(gr[i].value);
            }
          }
          load(r);
          expect(pr.value, equals((data.pr + 2) & 0xffff));
          for (var i = 0; i < 8; i++) {
            expect(gr[i].value, equals(expectGR[i]));
          }
          expect(fr.isOverflow, equals(false));
          expect(fr.isSign, equals((gr[data.r.value].value & 0x8000) > 0));
          expect(fr.isZero, equals(gr[data.r.value].value == 0));
        });
      }
    });
  });
}
