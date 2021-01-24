import 'dart:math';

import 'package:tiamat/src/comet2/instruction/instruction.dart';
import 'package:tiamat/src/comet2/resource.dart';
import 'package:test/test.dart';

import 'util.dart' as util;

void main() {
  final rand = Random();

  group('load address', () {
    final testdata = List.generate(
      32,
      (final i) => util.TestData(
        util.Entity(rand.nextInt(8)),
        util.Entity(rand.nextInt(8), rand.nextInt(0x10000)),
        adr: util.Entity(rand.nextInt(0x10000)),
        pr: rand.nextInt(0x10000),
      ),
    );

    const operand = 0x1200;
    final r = Resource();
    for (var i = 0; i < testdata.length; i++) {
      test('$i', () {
        final data = testdata[i];
        final op = operand | data.r.value << 4 | data.x.value;

        final pr = r.programRegister;
        final gr = r.generalRegisters;
        final fr = r.flagRegister;

        pr.value = data.pr;
        gr[data.x.value].value = data.x.data;
        r.memory[data.pr] = op;
        r.memory[data.pr + 1] = data.adr.value;

        final flag = util.Flag(
          overflow: fr.isOverflow,
          sign: fr.isSign,
          zero: fr.isZero,
        );
        final expectGR = <int>[];
        for (var i = 0; i < 8; i++) {
          if (i == data.r.value) {
            if (data.x.value > 0) {
              expectGR.add(data.x.data + data.adr.value);
            } else {
              expectGR.add(data.adr.value);
            }
          } else {
            expectGR.add(gr[i].value);
          }
        }
        loadAddress(r);
        expect(pr.value, equals((data.pr + 2) & 0xffff));
        for (var i = 0; i < 8; i++) {
          expect(gr[i].value, equals(expectGR[i] & 0xffff));
        }
        expect(fr.isOverflow, equals(flag.overflow));
        expect(fr.isSign, equals(flag.sign));
        expect(fr.isZero, equals(flag.zero));
      });
    }
  });
}
