import 'dart:math';

import 'package:tiamat/src/instruction.dart';
import 'package:tiamat/src/resource.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  test('no operation', () {
    final r = Resource();
    final ins = Instruction();

    expect(r.PR, equals(0));
    ins.noOperation(r);
    expect(r.PR, equals(1));

    for (var i = 0; i < 8; i++) {
      r.PR = 0;
      final count = rand.nextInt(1 << 16);
      for (var j = 0; j < count; j++) {
        ins.noOperation(r);
      }
      expect(r.PR, equals(count));
    }

    r.PR = (1 << 16) - 1;
    ins.noOperation(r);
    expect(r.PR, equals(0));
  });

  group('load memory', () {
    test('without base', () {
      final r = Resource();
      final ins = Instruction();

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

        ins.loadMemory(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(reg), equals(data));
      }
    });

    test('with base', () {
      final r = Resource();
      final ins = Instruction();

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

        ins.loadMemory(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(reg), equals(data));
      }
    });
  });

  test('load', () {
    final r = Resource();
    final ins = Instruction();

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

      ins.load(r);
      expect(r.PR, equals(pr + 1));
      expect(r.getGR(r1), equals(data));
    }
  });

  group('store', () {
    test('without base', () {
      final r = Resource();
      final ins = Instruction();

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

        ins.store(r);
        expect(r.PR, equals(pr + 2));
        expect(r.memory.getWord(addr), equals(data));
      }
    });

    test('with base', () {
      final r = Resource();
      final ins = Instruction();

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

        ins.store(r);
        expect(r.PR, equals(pr + 2));
        expect(r.memory.getWord(base + addr), equals(data));
      }
    });
  });

  group('load address', () {
    test('without base', () {
      final r = Resource();
      final ins = Instruction();

      for (var i = 0; i < 8; i++) {
        final reg = rand.nextInt(8);
        final pr = rand.nextInt((1 << 15) - 1) + 1;
        final addr = rand.nextInt(1 << 15) + (1 << 15);

        final op = (0x14 << 0x8) + (reg << 0x4);

        r.memory.setWord(pr, op);
        r.memory.setWord(pr + 1, addr);
        r.PR = pr;

        ins.loadAddress(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(reg), equals(addr));
      }
    });

    test('with base', () {
      final r = Resource();
      final ins = Instruction();

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

        ins.loadAddress(r);
        expect(r.PR, equals(pr + 2));
        expect(r.getGR(reg), equals(base + addr));
      }
    });
  });
}
