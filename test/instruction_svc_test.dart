import 'dart:math';

import 'package:tiamat/src/instruction.dart';
import 'package:tiamat/src/supervisorcall.dart';
import 'package:tiamat/src/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('svc 1', () {
    test('without base', () {
      final r = Resource();
      final svc = SVC();

      const text = 'Hello, World';
      svc.read = () => text;
      r.setGR(1, 0x8000);
      r.setGR(2, text.length);

      r.memory.setWord(r.PR, 0xf000);
      r.memory.setWord(r.PR + 1, 1);

      supervisorCall(r, svc);

      const e = [
        0x48,
        0x65,
        0x6c,
        0x6c,
        0x6f,
        0x2c,
        0x20,
        0x57,
        0x6f,
        0x72,
        0x6c,
        0x64,
        0,
      ];

      for (var i = 0; i < e.length; i++) {
        expect(r.memory.getWord(0x8000 + i), equals(e[i]));
      }
    });
  });
}
