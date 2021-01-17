import 'dart:math';

import 'package:tiamat/src/resource/register.dart';
import 'package:test/test.dart';

class TestData {
  final String name;
  final int value;
  final int bits;
  TestData({
    required this.name,
    required this.value,
    required this.bits,
  });
}

void main() {
  final rand = Random();

  group('register', () {
    final testdata = [
      for (var i = 0; i < 64; i++)
        TestData(
          name: 'GR$i',
          value: rand.nextInt(0x10000),
          bits: rand.nextInt(16),
        ),
    ];

    for (var i = 0; i < testdata.length; i++) {
      test('$i', () {
        final data = testdata[i];
        final r = Register(
          data.name,
          value: data.value,
          bits: data.bits,
        );

        expect(r.name, equals(data.name));
        r.value = data.value;
        expect(r.value, equals(data.value.toUnsigned(data.bits)));
      });
    }
  });
}
