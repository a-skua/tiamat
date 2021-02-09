import 'dart:math';

import 'package:tiamat/src/casl2/instruction.dart';
import 'package:test/test.dart';

import '../util/util.dart';

void main() {
  test('RPUSH', () {
    expect(
      rpush('FOO').code,
      equals([
        0x7001,
        0,
        0x7002,
        0,
        0x7003,
        0,
        0x7004,
        0,
        0x7005,
        0,
        0x7006,
        0,
        0x7007,
        0,
      ]),
    );
    expect(rpush('FOO').label, equals('FOO'));
  });

  test('RPOP', () {
    expect(
      rpop('FOO').code,
      equals([
        0x7170,
        0x7160,
        0x7150,
        0x7140,
        0x7130,
        0x7120,
        0x7110,
      ]),
    );
    expect(
      rpop('FOO').label,
      equals('FOO'),
    );
  });
}
