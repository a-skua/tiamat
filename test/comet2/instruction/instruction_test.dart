import 'dart:math';

import 'package:tiamat/src/comet2/instruction/instruction.dart';
import 'package:tiamat/src/resource/resource.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  test('no operation', () {
    final r = Resource();

    expect(r.PR, equals(0));
    noOperation(r);
    expect(r.PR, equals(1));

    for (var i = 0; i < 8; i++) {
      r.PR = 0;
      final count = rand.nextInt(1 << 16);
      for (var j = 0; j < count; j++) {
        noOperation(r);
      }
      expect(r.PR, equals(count));
    }

    r.PR = (1 << 16) - 1;
    noOperation(r);
    expect(r.PR, equals(0));
  });

  group('store', () {
    test('without base', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final reg = rand.nextInt(8);
        final pr = rand.nextInt((1 << 15) - 1) + 1;
        final addr = rand.nextInt(1 << 15) + (1 << 15);

        final op = (0x12 << 0x8) + (reg << 0x4);
        final data = rand.nextInt(1 << 16);

        r.setGR(reg, data);
        r.memory.setWord(addr, 0);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, addr);
        r.PR = pr;

        store(r);
        expect(r.PR, equals(pr + 2));
        expect(r.memory.getWord(addr), equals(data));
      }
    });

    test('with base', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final reg = rand.nextInt(8);
        var baseReg = 1 + rand.nextInt(7);
        if (reg == baseReg) {
          baseReg = baseReg == 7 ? 1 : baseReg + 1;
        }
        final pr = rand.nextInt((1 << 15) - 1) + 1;
        final base = rand.nextInt(1 << 14);
        final addr = rand.nextInt(1 << 14) + (1 << 15);

        final op = (0x12 << 0x8) + (reg << 0x4) + baseReg;
        final data = rand.nextInt(1 << 16);

        r.setGR(reg, data);
        r.setGR(baseReg, base);
        r.memory.setWord(base + addr, 0);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, addr);
        r.PR = pr;

        store(r);
        expect(r.PR, equals(pr + 2));
        expect(r.memory.getWord(base + addr), equals(data));
      }
    });
  });

  group('load address', () {
    test('without base', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final reg = rand.nextInt(8);
        final pr = rand.nextInt((1 << 15) - 1) + 1;
        final addr = rand.nextInt(1 << 15) + (1 << 15);

        final op = (0x14 << 0x8) + (reg << 0x4);

        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, addr);
        r.PR = pr;

        loadAddress(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(reg), equals(addr));
      }
    });

    test('with base', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final reg = rand.nextInt(8);
        final baseReg = 1 + rand.nextInt(7);
        final pr = rand.nextInt((1 << 15) - 1) + 1;
        final base = rand.nextInt(1 << 14);
        final addr = rand.nextInt(1 << 14) + (1 << 15);

        final op = (0x14 << 0x8) + (reg << 0x4) + baseReg;

        r.setGR(baseReg, base);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, addr);
        r.PR = pr;

        loadAddress(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(reg), equals(base + addr));
      }
    });
  });

  /// TODO
  // group('supervisor call', () {
  //   test('default', () {
  //     final r = Resource();

  //     final op = 0xf000;

  //     {
  //       final pr = r.PR;
  //       r.memory.setWord(r.PR, op);
  //       r.memory.setWord(r.PR + 1, 1);

  //       supervisorCall(r);
  //     }
  //   });
  // });
}
