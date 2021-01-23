import 'dart:math';

import 'package:tiamat/src/comet2/instruction/shift_left_arithmetic.dart';
import 'package:tiamat/src/resource/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('shift left arithmetic', () {
    group('r,adr,x', () {
      final testdata = [
        ...List.generate(8, (_) {
          final r = rand.nextInt(8);
          return TestData(
            Entity(r),
            Entity(getX(r), rand.nextInt(8)),
            adr: Entity(rand.nextInt(8)),
            pr: rand.nextInt(0xffff),
          );
        }),
        ...List.generate(32, (_) {
          final r = rand.nextInt(8);
          return TestData(
            Entity(r, rand.nextInt(0x10000).toSigned(16)),
            Entity(getX(r), rand.nextInt(8)),
            adr: Entity(rand.nextInt(8)),
            pr: rand.nextInt(0xffff),
          );
        }),
      ];

      const operand = 0x5000;
      final r = Resource();
      for (var i = 0; i < testdata.length; i++) {
        test('$i', () {
          final data = testdata[i];
          final op = operand | data.r.value << 4 | data.x.value;

          final pr = r.programRegister;
          final gr = r.generalRegisters;
          final fr = r.flagRegister;
          final ram = r.memory;

          pr.value = data.pr;
          gr[data.r.value].value = data.r.data;
          gr[data.x.value].value = data.x.data;
          ram[data.pr] = op;
          ram[data.pr + 1] = data.adr.value;

          final expectGR = <int>[];
          for (var i = 0; i < 8; i++) {
            if (i == data.r.value) {
              if (data.x.value > 0) {
                expectGR.add(
                    (data.r.data << (data.x.data + data.adr.value)) & 0xffff);
              } else {
                expectGR.add((data.r.data << data.adr.value) & 0xffff);
              }
            } else {
              expectGR.add(gr[i].value);
            }
          }

          shiftLeftArithmetic(r);
          expect(pr.value, equals((data.pr + 2) & 0xffff));
          for (var i = 0; i < 8; i++) {
            expect(gr[i].value, equals(expectGR[i]));
          }
          final result = data.x.value > 0
              ? data.r.data << (data.x.data + data.adr.value)
              : data.r.data << data.adr.value;
          expect(fr.isOverflow, equals((result & 0x10000) > 0));
          expect(fr.isSign, equals((result & 0x8000) > 0));
          expect(fr.isZero, equals(result == 0));
        });
      }
    });
  });
}
