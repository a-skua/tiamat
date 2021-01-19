import 'dart:math';

import 'package:tiamat/src/resource/flag.dart';
import 'package:test/test.dart';

class TestData {
  final bool overflow;
  final bool sign;
  final bool zero;
  TestData({
    this.overflow = false,
    this.sign = false,
    this.zero = false,
  });
}

void main() {
  final rand = Random();

  group('flag register', () {
    test('check flag', () {
      expect(Flag.overflow, isNot(equals(Flag.sign)));
      expect(Flag.overflow, isNot(equals(Flag.zero)));
      expect(Flag.sign, isNot(equals(Flag.zero)));
    });

    test('set name', () {
      final flag = FlagRegister(name: 'foo');

      expect(flag.name, equals('foo'));
    });

    for (var i = 0; i < 8; i++) {
      test('value to flag $i', () {
        final data = TestData(
          overflow: i & Flag.overflow > 0,
          sign: i & Flag.sign > 0,
          zero: i & Flag.zero > 0,
        );

        final flag = FlagRegister()..value = i;

        expect(flag.value, equals(i));
        expect(flag.overflow, equals(data.overflow));
        expect(flag.sign, equals(data.sign));
        expect(flag.zero, equals(data.zero));
        expect(flag.value, equals(i));
        expect(flag.name, equals('FR'));
      });

      test('flag to value', () {
        final data = TestData(
          overflow: i & Flag.overflow > 0,
          sign: i & Flag.sign > 0,
          zero: i & Flag.zero > 0,
        );

        final flag = FlagRegister();
        expect(flag.overflow, equals(false));
        expect(flag.sign, equals(false));
        expect(flag.zero, equals(false));
        expect(flag.value, equals(0));
        expect(flag.name, equals('FR'));

        flag.overflow = data.overflow;
        flag.sign = data.sign;
        flag.zero = data.zero;

        expect(flag.overflow, equals(data.overflow));
        expect(flag.sign, equals(data.sign));
        expect(flag.zero, equals(data.zero));
        expect(flag.value, equals(i));
        expect(flag.name, equals('FR'));
      });
    }
  });
}
