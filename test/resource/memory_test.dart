import 'dart:math';

import 'package:tiamat/src/resource/memory.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('memory', () {
    group('get/set', () {
      final testdata = [
        TestData(-1, rand.nextInt(0x10000)),
        for (var i = 0; i < 8; i++)
          TestData(
            -rand.nextInt(0x10000),
            rand.nextInt(0x10000),
          ),
        TestData(0x10000, rand.nextInt(0x10000)),
        for (var i = 0; i < 8; i++)
          TestData(
            rand.nextInt(0x10000) | 0x10000,
            rand.nextInt(0x10000),
          ),
        TestData(rand.nextInt(0x10000), -1),
        for (var i = 0; i < 8; i++)
          TestData(
            rand.nextInt(0x10000),
            -rand.nextInt(0x10000),
          ),
        for (var i = 0; i < 8; i++)
          TestData(
            rand.nextInt(0x10000),
            rand.nextInt(0x10000) | 0x10000,
          ),
        for (var i = 0; i < 24; i++)
          TestData(
            rand.nextInt(0x10000),
            rand.nextInt(0x10000),
          ),
      ];

      for (var i = 0; i < testdata.length; i++) {
        test('$i', () {
          final d = testdata[i];
          final m = Memory();

          m.setWord(d.address, d.value);
          expect(m.getWord(d.address), equals(d.value & 0xffff));
          expect(m.getWord(d.address & 0xffff), equals(d.value & 0xffff));
        });
      }
    });
  });
}
