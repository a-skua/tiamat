import 'dart:math';

import 'package:tiamat/src/comet2/resource.dart';
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
          value: rand.nextInt(0x100000),
          bits: rand.nextInt(16) | 1,
        ),
    ];

    for (var i = 0; i < testdata.length; i++) {
      test('$i', () {
        final data = testdata[i];
        final r = Register(
          data.name,
          bits: data.bits,
        )..value = data.value;

        expect(r.name, equals(data.name));
        expect(r.bits, equals(data.bits));
        expect(r.maskBits, equals((-1).toUnsigned(data.bits)));
        expect(r.value, equals(data.value.toUnsigned(data.bits)));
        expect(r.signed, equals(data.value.toSigned(data.bits)));
        {
          final value = data.value + rand.nextInt(0x8000);
          r.value = value;
          expect(r.value, equals(value.toUnsigned(data.bits)));
          expect(r.signed, equals(value.toSigned(data.bits)));
        }
      });
    }
  });
}
