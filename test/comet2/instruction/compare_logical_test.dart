import 'dart:math';

import 'package:tiamat/src/comet2/instruction/compare_logical.dart';
import 'package:tiamat/src/resource/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('compare logical', () {
    group('r1,r2', () {
      final testdata = [
        ...List.generate(8, (_) {
          final r1 = rand.nextInt(8);
          return TestData(
            Entity(r1),
            Entity(getR2(r1)),
            pr: rand.nextInt(0x10000),
            fr: rand.nextInt(8),
          );
        }),
        ...List.generate(32, (_) {
          final r1 = rand.nextInt(8);
          return TestData(
            Entity(r1, rand.nextInt(0x10000)),
            Entity(getR2(r1), rand.nextInt(0x10000)),
            pr: rand.nextInt(0x10000),
            fr: rand.nextInt(8),
          );
        }),
      ];

      const operand = 0x4500;
      final r = Resource();
      for (var i = 0; i < testdata.length; i++) {
        test('$i', () {
          final data = testdata[i];
          final op = operand | data.r1.value << 4 | data.r2.value;

          final pr = r.programRegister;
          final gr = r.generalRegisters;
          final fr = r.flagRegister;

          pr.value = data.pr;
          fr.value = data.fr;
          gr[data.r1.value].value = data.r1.data;
          gr[data.r2.value].value = data.r2.data;
          r.memory[data.pr] = op;

          final expectGR = <int>[];
          for (var i = 0; i < 8; i++) {
            expectGR.add(gr[i].value);
          }

          compareLogicalGR(r);
          expect(pr.value, equals((data.pr + 1) & 0xffff));
          for (var i = 0; i < 8; i++) {
            expect(gr[i].value, equals(expectGR[i]));
          }
          expect(fr.overflow, equals(false));
          expect(fr.sign, equals(data.r1.data < data.r2.data));
          expect(fr.zero, equals(data.r1.data == data.r2.data));
        });
      }
    });

    group('r,adr,x', () {
      final testdata = [
        ...List.generate(8, (_) {
          final r = rand.nextInt(8);
          return TestData(
            Entity(r),
            Entity(getX(r), rand.nextInt(0x4000)),
            adr: Entity(rand.nextInt(0x4000) | 0x8000),
            pr: rand.nextInt(0x7fff),
            fr: rand.nextInt(8),
          );
        }),
        ...List.generate(32, (_) {
          final r = rand.nextInt(8);
          return TestData(
            Entity(r, rand.nextInt(0x10000)),
            Entity(getX(r), rand.nextInt(0x4000)),
            adr: Entity(
              rand.nextInt(0x4000) | 0x80000,
              rand.nextInt(0x10000),
            ),
            pr: rand.nextInt(0x7fff),
            fr: rand.nextInt(8),
          );
        }),
      ];

      const operand = 0x4500;
      final r = Resource();
      for (var i = 0; i < testdata.length; i++) {
        test('$i', () {
          final data = testdata[i];
          final op = operand | data.r.value << 4 | data.x.value;

          final pr = r.programRegister;
          final gr = r.generalRegisters;
          final fr = r.flagRegister;

          pr.value = data.pr;
          fr.value = data.fr;
          gr[data.r.value].value = data.r.data;
          r.memory[data.pr] = op;
          r.memory[data.pr + 1] = data.adr.value;
          if (data.x.value > 0) {
            gr[data.x.value].value = data.x.data;
            r.memory[data.x.data + data.adr.value] = data.adr.data;
          } else {
            r.memory[data.adr.value] = data.adr.data;
          }

          final expectGR = <int>[];
          for (var i = 0; i < 8; i++) {
            expectGR.add(gr[i].value);
          }

          compareLogical(r);
          expect(pr.value, equals((data.pr + 2) & 0xffff));
          for (var i = 0; i < 8; i++) {
            expect(gr[i].value, equals(expectGR[i]));
          }
          expect(fr.overflow, equals(false));
          expect(fr.sign, equals(data.r.data < data.adr.data));
          expect(fr.zero, equals(data.r.data == data.adr.data));
        });
      }
    });
  });
}
