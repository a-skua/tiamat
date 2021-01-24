import 'dart:math';

import 'package:tiamat/src/comet2/instruction.dart';
import 'package:tiamat/src/comet2/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('call subroutine', () {
    group('adr,x', () {
      final testdata = [
        ...List.generate(8, (_) {
          final r = rand.nextInt(8);
          return TestData(
            Entity(r),
            Entity(getX(r)),
            adr: Entity(rand.nextInt(0x10000)),
            pr: rand.nextInt(0x7fff),
            fr: rand.nextInt(8),
          );
        }),
        ...List.generate(32, (_) {
          final r = rand.nextInt(8);
          return TestData(
            Entity(r),
            Entity(getX(r), rand.nextInt(0x10000)),
            adr: Entity(rand.nextInt(0x10000)),
            pr: rand.nextInt(0x7fff),
            fr: rand.nextInt(8),
          );
        }),
      ];

      const operand = 0x8000;
      final r = Resource();
      for (var i = 0; i < testdata.length; i++) {
        test('$i', () {
          final data = testdata[i];
          final op = operand | data.r1.value << 4 | data.r2.value;

          final pr = r.programRegister;
          final gr = r.generalRegisters;
          final fr = r.flagRegister;
          final sp = r.stackPointer;
          final ram = r.memory;

          pr.value = data.pr;
          fr.value = data.fr;
          gr[data.x.value].value = data.x.data;
          ram[data.pr] = op;
          ram[data.pr + 1] = data.adr.value;

          final expectGR = <int>[];
          for (var i = 0; i < 8; i++) {
            expectGR.add(gr[i].value);
          }
          final expectSP = sp.value - 1;

          callSubroutine(r);
          if (data.x.value > 0) {
            expect(pr.value, equals((data.x.data + data.adr.value) & 0xffff));
          } else {
            expect(pr.value, equals(data.adr.value & 0xffff));
          }
          expect(fr.value, equals(data.fr & 7));
          expect(sp.value, equals(expectSP & 0xffff));
          for (var i = 0; i < 8; i++) {
            expect(gr[i].value, equals(expectGR[i]));
          }
        });
      }
    });
  });
}
