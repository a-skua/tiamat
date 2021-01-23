import 'dart:math';

import 'package:tiamat/src/comet2/instruction/jump_on_zero.dart';
import 'package:tiamat/src/resource/resource.dart';
import 'package:tiamat/src/resource/flag.dart';
import 'package:test/test.dart';

import 'util.dart' show TestData, Entity, getX;

void main() {
  final rand = Random();

  group('jump on zero', () {
    group('adr,x', () {
      final testdata = [
        ...List.generate(8, (_) {
          final r = rand.nextInt(8);
          return TestData(
            Entity(r),
            Entity(getX(r)),
            adr: Entity(rand.nextInt(0x100000)),
            pr: rand.nextInt(0x100000),
            fr: rand.nextInt(8),
          );
        }),
        ...List.generate(32, (_) {
          final r = rand.nextInt(8);
          return TestData(
            Entity(r),
            Entity(getX(r), rand.nextInt(0x100000)),
            adr: Entity(rand.nextInt(0x100000)),
            pr: rand.nextInt(0x100000),
            fr: rand.nextInt(8),
          );
        }),
      ];

      const operand = 0x6300;
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
          gr[data.x.value].value = data.x.data;
          r.memory[data.pr] = op;
          r.memory[data.pr + 1] = data.adr.value;

          final expectGR = <int>[];
          for (var i = 0; i < 8; i++) {
            expectGR.add(gr[i].value);
          }

          jumpOnZero(r);
          for (var i = 0; i < 8; i++) {
            expect(gr[i].value, equals(expectGR[i]));
          }
          final address =
              data.x.value > 0 ? data.x.data + data.adr.value : data.adr.value;
          expect(fr.value, equals(data.fr & 7));
          if (data.fr & Flag.zero > 0) {
            expect(pr.value, equals(address & 0xffff));
          } else {
            expect(pr.value, equals((data.pr + 2) & 0xffff));
          }
        });
      }
    });
  });
}
