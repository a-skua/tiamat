import 'dart:math';

import 'package:tiamat/src/resource/memory.dart';
import 'package:test/test.dart';

class TestData4Constructor {
  final int length;
  final int bits;
  TestData4Constructor({
    this.length = 0x10000,
    this.bits = 16,
  });
}

class TestData4SetAll {
  final int address;
  final List<int> values;
  TestData4SetAll({
    this.address = 0,
    this.values = const [],
  });
}

class TestData4GetAndSet {
  final int address;
  final int value;
  const TestData4GetAndSet({
    this.address = 0,
    this.value = 0,
  });
}

void main() {
  final rand = Random();

  group('memory', () {
    group('constructor', () {
      final testdata = [
        TestData4Constructor(),
        for (var i = 0; i < 8; i++)
          TestData4Constructor(
            length: rand.nextInt(0x10000),
            bits: rand.nextInt(16),
          ),
      ];

      for (var i = 0; i < testdata.length; i++) {
        test('$i', () {
          final data = testdata[i];

          final memory = Memory(
            length: data.length,
            bits: data.bits,
          );
          expect(memory.length, equals(data.length));
          expect(memory.bits, equals(data.bits));
          expect(memory.maskBits, equals((-1).toUnsigned(data.bits)));

          final address = rand.nextInt(data.length);
          final value = rand.nextInt(0x10000);
          memory[address] = value;
          expect(memory[address], equals(value & (-1).toUnsigned(data.bits)));
        });
      }
    });

    group('setAll', () {
      final testdata = [
        for (var i = 0; i < 8; i++)
          TestData4SetAll(
            address: rand.nextInt(0x4000),
            values: List.generate(
              rand.nextInt(0x4000),
              (_) => rand.nextInt(0x10000),
            ),
          ),
      ];

      for (var i = 0; i < testdata.length; i++) {
        test('$i', () {
          final data = testdata[i];
          final memory = Memory();

          memory.setAll(data.address, data.values);
          for (var i = 0; i < data.values.length; i++) {
            final address = data.address + i;
            expect(memory[address], equals(data.values[i]));
          }
        });
      }
    });

    group('get and set', () {
      final testdata = [
        TestData4GetAndSet(
          address: -1,
          value: rand.nextInt(0x10000),
        ),
        for (var i = 0; i < 8; i++)
          TestData4GetAndSet(
            address: -rand.nextInt(0x10000),
            value: rand.nextInt(0x10000),
          ),
        TestData4GetAndSet(
          address: 0x10000,
          value: rand.nextInt(0x10000),
        ),
        for (var i = 0; i < 8; i++)
          TestData4GetAndSet(
            address: rand.nextInt(0x10000) | 0x10000,
            value: rand.nextInt(0x10000),
          ),
        TestData4GetAndSet(
          address: rand.nextInt(0x10000),
          value: -1,
        ),
        for (var i = 0; i < 8; i++)
          TestData4GetAndSet(
            address: rand.nextInt(0x10000),
            value: -rand.nextInt(0x10000),
          ),
        for (var i = 0; i < 8; i++)
          TestData4GetAndSet(
            address: rand.nextInt(0x10000),
            value: rand.nextInt(0x10000) | 0x10000,
          ),
        for (var i = 0; i < 24; i++)
          TestData4GetAndSet(
            address: rand.nextInt(0x10000),
            value: rand.nextInt(0x10000),
          ),
      ];

      for (var i = 0; i < testdata.length; i++) {
        test('$i', () {
          final data = testdata[i];
          final memory = Memory();

          expect(memory[data.address], equals(0));
          expect(memory[data.address % memory.length], equals(0));

          memory[data.address] = data.value;
          expect(memory[data.address], equals(data.value & 0xffff));
          expect(memory[data.address % memory.length],
              equals(data.value & 0xffff));
        });
      }
    });
  });
}
