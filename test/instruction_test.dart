import 'dart:math';

import 'package:tiamat/src/instruction.dart';
import 'package:tiamat/src/resource.dart';
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

  group('load memory', () {
    test('without base', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final reg = rand.nextInt(8);
        final pr = rand.nextInt((1 << 15) - 1) + 1;
        final addr = rand.nextInt(1 << 15) + (1 << 15);

        final op = (0x10 << 0x8) + (reg << 0x4);
        final data = rand.nextInt(1 << 16);

        r.setGR(reg, 0);
        r.memory.setWord(addr, data);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, addr);
        r.PR = pr;

        loadMemory(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(reg), equals(data));
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

        final op = (0x10 << 0x8) + (reg << 0x4) + baseReg;
        final data = rand.nextInt(1 << 16);

        r.setGR(reg, 0);
        r.setGR(baseReg, base);
        r.memory.setWord(base + addr, data);
        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, addr);
        r.PR = pr;

        loadMemory(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(reg), equals(data));
      }
    });

    test('flags', () {
      final r = Resource();

      var op = (0x10 << 0x8);
      var base = 0;
      var addr = ((1 << 16) - 1) - base;
      var data = 0;

      r.memory.setWord(r.PR, op);
      r.memory.setWord(r.PR + 1, addr);
      r.memory.setWord(addr + base, data);
      loadMemory(r);
      expect(r.OF, equals(false));
      expect(r.SF, equals(false));
      expect(r.ZF, equals(true));
      expect(r.getGR(0), equals(data));

      op = (0x10 << 0x8) + (0x1 << 0x4) + 0x1;
      base = 10;
      addr = ((1 << 16) - 1) - base;
      data = 1 << 15;

      r.setGR(1, base);
      r.memory.setWord(r.PR, op);
      r.memory.setWord(r.PR + 1, addr);
      r.memory.setWord(addr + base, data);
      loadMemory(r);
      expect(r.OF, equals(false));
      expect(r.SF, equals(true));
      expect(r.ZF, equals(false));
      expect(r.getGR(1), equals(data));

      op = (0x10 << 0x8) + (0x7 << 0x4) + 0x2;
      base = 20;
      addr = ((1 << 16) - 1) - base;
      data = rand.nextInt(1 << 15);

      r.setGR(2, base);
      r.memory.setWord(r.PR, op);
      r.memory.setWord(r.PR + 1, addr);
      r.memory.setWord(addr + base, data);
      loadMemory(r);
      expect(r.OF, equals(false));
      expect(r.SF, equals(false));
      expect(r.ZF, equals(false));
      expect(r.getGR(7), equals(data));
    });
  });

  group('load', () {
    test('default', () {
      final r = Resource();

      for (var i = 0; i < 8; i++) {
        final r1 = rand.nextInt(8);
        final r2 = rand.nextInt(8);
        final pr = rand.nextInt(1 << 16);

        final op = (0x14 << 0x8) + (r1 << 0x4) + r2;
        final data = rand.nextInt(1 << 16);

        r.setGR(r1, 0);
        r.setGR(r2, data);
        r.memory.setWord(pr, op);
        r.PR = pr;

        load(r);
        expect(r.PR, equals(pr + 1));
        expect(r.getGR(r1), equals(data));
      }
    });

    test('flags', () {
      final r = Resource();

      var r1 = rand.nextInt(8);
      var r2 = rand.nextInt(8);
      var op = (0x14 << 8) + (r1 << 4) + r2;
      var data = 0;

      r.setGR(r2, data);
      r.FR = 6;
      r.memory.setWord(r.PR, op);
      load(r);
      expect(r.getGR(r1), equals(data));
      expect(r.OF, equals(false));
      expect(r.SF, equals(false));
      expect(r.ZF, equals(true));

      r1 = rand.nextInt(8);
      r2 = rand.nextInt(8);
      op = (0x14 << 8) + (r1 << 4) + r2;
      data = 1 << 15;

      r.setGR(r2, data);
      r.FR = 5;
      r.memory.setWord(r.PR, op);
      load(r);
      expect(r.getGR(r1), equals(data));
      expect(r.OF, equals(false));
      expect(r.SF, equals(true));
      expect(r.ZF, equals(false));

      r1 = rand.nextInt(8);
      r2 = rand.nextInt(8);
      op = (0x14 << 8) + (r1 << 4) + r2;
      data = rand.nextInt(1 << 15);

      r.setGR(r2, data);
      r.FR = 7;
      r.memory.setWord(r.PR, op);
      load(r);
      expect(r.getGR(r1), equals(data));
      expect(r.OF, equals(false));
      expect(r.SF, equals(false));
      expect(r.ZF, equals(false));
    });
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
