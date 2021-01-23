import 'dart:math';

import 'package:tiamat/src/comet2/instruction/pop.dart';
import 'package:tiamat/src/resource/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('pop', () {
    group('r', () {
      final testdata = List.generate(
        32,
        (_) => TestData(
          Entity(rand.nextInt(8)),
          Entity(0),
          adr: Entity(rand.nextInt(0x10000)),
          pr: rand.nextInt(0x7fff),
          fr: rand.nextInt(8),
        ),
      );

      const operand = 0x7100;
      final r = Resource()..stackPointer.value = 0x7fff;
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
          ram[data.pr] = op;
          ram[sp.value] = data.adr.value;

          final expectGR = <int>[];
          for (var i = 0; i < 8; i++) {
            if (i == data.r.value) {
              expectGR.add(data.adr.value & 0xffff);
            } else {
              expectGR.add(gr[i].value);
            }
          }
          final expectSP = sp.value + 1;

          pop(r);
          expect(pr.value, equals((data.pr + 1) & 0xffff));
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
