import 'dart:math';

import 'package:tiamat/src/casl2/instruction.dart';
import 'package:test/test.dart';

import '../util/util.dart';

void main() {
  test('IN', () {
    expect(
      input('FOO', '#00F0,10').code,
      equals([
        0x7001,
        0,
        0x7002,
        0,
        0x1210,
        0xf0,
        0x1220,
        10,
        0xf000,
        1,
        0x7120,
        0x7110,
      ]),
    );
    expect(
      input('FOO', '#00F0,10').label,
      equals('FOO'),
    );
  });

  test('OUT', () {
    expect(
      output('FOO', '#00F0,10').code,
      equals([
        0x7001,
        0,
        0x7002,
        0,
        0x1210,
        0xf0,
        0x1220,
        10,
        0xf000,
        2,
        0x7120,
        0x7110,
      ]),
    );
    expect(
      output('FOO', '#00F0,10').label,
      equals('FOO'),
    );
  });

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
