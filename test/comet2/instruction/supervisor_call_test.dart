import 'dart:math';

import 'package:tiamat/src/comet2/instruction/instruction.dart';
import 'package:tiamat/src/comet2/comet2.dart';
import 'package:tiamat/src/util/charcode.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('supervisor call', () {
    group('1 (read)', () {
      final testdata = [
        TestData(
          Entity(0),
          Entity(0),
          adr: Entity(1),
          pr: rand.nextInt(0x7fff),
          fr: rand.nextInt(8),
        ),
        ...List.generate(16, (_) {
          return TestData(
            Entity(0),
            // GR3 <= x <= GR7
            Entity(rand.nextInt(5) + 3, 1),
            adr: Entity(0),
            pr: rand.nextInt(0x7fff),
            fr: rand.nextInt(8),
          );
        }),
      ];

      const operand = 0xf000;
      final comet2 = Comet2();
      final r = comet2.resource;
      for (var i = 0; i < testdata.length; i++) {
        test('$i', () {
          final data = testdata[i];
          final op = operand | data.r.value << 4 | data.x.value;
          final value = 'hello, test $i';

          comet2.device.input = () => value;

          final pr = r.programRegister;
          final gr = r.generalRegisters;
          final fr = r.flagRegister;
          final sp = r.stackPointer;
          final ram = r.memory;

          final buf = rand.nextInt(0x4000) | 0x8000;
          final len = value.length;

          pr.value = data.pr;
          fr.value = data.fr;
          gr[1].value = buf;
          gr[2].value = len;
          gr[data.x.value].value = data.x.data;
          ram[data.pr] = op;
          ram[data.pr + 1] = data.adr.value;

          supervisorCall(r);
          expect(pr.value, equals((data.pr + 2) & 0xffff));
          expect(fr.value, equals(data.fr & 7));
          final expectedChars = value.split('');
          for (var i = 0; i < len; i++) {
            expect(ram[buf + i], equals(char2code[expectedChars[i]]));
          }
        });
      }
    });

    group('2 (write)', () {
      final testdata = [
        TestData(
          Entity(0),
          Entity(0),
          adr: Entity(2),
          pr: rand.nextInt(0x7fff),
          fr: rand.nextInt(8),
        ),
        ...List.generate(16, (_) {
          return TestData(
            Entity(0),
            // GR3 <= x <= GR7
            Entity(rand.nextInt(5) + 3, 2),
            adr: Entity(0),
            pr: rand.nextInt(0x7fff),
            fr: rand.nextInt(8),
          );
        }),
      ];

      const operand = 0xf000;
      final comet2 = Comet2();
      final r = comet2.resource;
      for (var i = 0; i < testdata.length; i++) {
        test('$i', () {
          final data = testdata[i];
          final op = operand | data.r.value << 4 | data.x.value;
          final expectedStr = 'hello, test $i';
          var value = '';

          comet2.device.output = (final String s) => value = s;

          final pr = r.programRegister;
          final gr = r.generalRegisters;
          final fr = r.flagRegister;
          final sp = r.stackPointer;
          final ram = r.memory;

          final buf = rand.nextInt(0x4000) | 0x8000;
          final len = expectedStr.length;

          pr.value = data.pr;
          fr.value = data.fr;
          gr[1].value = buf;
          gr[2].value = len;
          gr[data.x.value].value = data.x.data;
          ram[data.pr] = op;
          ram[data.pr + 1] = data.adr.value;
          {
            final chars = expectedStr.split('');
            for (var i = 0; i < chars.length; i++) {
              ram[buf + i] = char2code[chars[i]] ?? 0;
            }
          }

          supervisorCall(r);
          expect(pr.value, equals((data.pr + 2) & 0xffff));
          expect(fr.value, equals(data.fr & 7));
          expect(value, equals(expectedStr));
        });
      }
    });
  });
}
