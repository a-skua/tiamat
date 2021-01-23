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

        final flag = FlagRegister();

        expect(flag.isOverflow, equals(false));
        expect(flag.isSign, equals(false));
        expect(flag.isZero, equals(false));
        expect(flag.isNotOverflow, equals(true));
        expect(flag.isNotSign, equals(true));
        expect(flag.isNotZero, equals(true));
        expect(flag.value, equals(0));
        expect(flag.name, equals('FR'));

        flag.value = i;
        expect(flag.value, equals(i));
        expect(flag.isOverflow, equals(data.overflow));
        expect(flag.isSign, equals(data.sign));
        expect(flag.isZero, equals(data.zero));
        expect(flag.isNotOverflow, equals(!data.overflow));
        expect(flag.isNotSign, equals(!data.sign));
        expect(flag.isNotZero, equals(!data.zero));
        expect(flag.value, equals(i));
        expect(flag.name, equals('FR'));
      });
    }
  });
}
