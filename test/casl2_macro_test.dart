import 'dart:math';

import 'package:tiamat/src/casl2.dart';
import 'package:tiamat/src/comet2.dart';
import 'package:tiamat/src/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  test('IN', () {
    final cc = Casl2();
    expect(
      cc.input('FOO', '#00F0,10').code,
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
      cc.input('FOO', '#00F0,10').label,
      equals('FOO'),
    );
  });

  test('OUT', () {
    final cc = Casl2();
    expect(
      cc.output('FOO', '#00F0,10').code,
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
      cc.output('FOO', '#00F0,10').label,
      equals('FOO'),
    );
  });

  test('RPUSH', () {
    final cc = Casl2();
    expect(
      cc.rpush('FOO').code,
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
    expect(cc.rpush('FOO').label, equals('FOO'));
  });

  test('RPOP', () {
    final cc = Casl2();
    expect(
      cc.rpop('FOO').code,
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
      cc.rpop('FOO').label,
      equals('FOO'),
    );
  });
}
