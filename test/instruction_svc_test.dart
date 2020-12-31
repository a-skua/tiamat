import 'dart:math';

import 'package:tiamat/src/instruction.dart';
import 'package:tiamat/src/supervisorcall.dart';
import 'package:tiamat/src/resource.dart';
import 'package:tiamat/src/charcode.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();

  group('svc 1', () {
    test('without base', () {
      final r = Resource();
      final sv = Supervisor();

      const text = 'Hello, World';
      sv.read = () => text;
      r.setGR(1, 0x8000);
      r.setGR(2, text.length);

      r.memory.setWord(r.PR, 0xf000);
      r.memory.setWord(r.PR + 1, 1);

      supervisorCall(r, sv);

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

    test('with base', () {
      final r = Resource();
      final sv = Supervisor();

      const text = 'Hello, World';
      sv.read = () => text;
      r.setGR(1, 0x8000);
      r.setGR(2, text.length);

      r.setGR(7, 1);
      r.memory.setWord(r.PR, 0xf007);
      r.memory.setWord(r.PR + 1, 0);

      supervisorCall(r, sv);

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

  group('svc 2', () {
    test('without base', () {
      final r = Resource();
      final sv = Supervisor();

      const text = 'hello, world!';
      var e = '';

      sv.write = (String s) {
        e = s;
      };
      r.setGR(1, 0x8000);
      r.setGR(2, text.length);

      r.memory.setWord(r.PR, 0xf000);
      r.memory.setWord(r.PR + 1, 2);
      {
        final s = text.split('');
        for (var i = 0; i < s.length; i++) {
          final c = s[i];
          r.memory.setWord(0x8000 + i, char2code[c] ?? 0);
        }
      }

      supervisorCall(r, sv);
      expect(e, equals(text));
    });

    test('with base', () {
      final r = Resource();
      final sv = Supervisor();

      const text = 'hello, world!';
      var e = '';

      sv.write = (String s) {
        e = s;
      };
      r.setGR(1, 0x8000);
      r.setGR(2, text.length);

      r.setGR(7, 1);
      r.memory.setWord(r.PR, 0xf007);
      r.memory.setWord(r.PR + 1, 1);
      {
        final s = text.split('');
        for (var i = 0; i < s.length; i++) {
          final c = s[i];
          r.memory.setWord(0x8000 + i, char2code[c] ?? 0);
        }
      }

      supervisorCall(r, sv);
      expect(e, equals(text));
    });
  });
}
