import 'dart:math';

import 'package:tiamat/src/casl2/core/node.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('node', () {
    group('type code', () {
      for (var i = 0; i < 16; i++) {
        test('$i', () {
          final code = rand.nextInt(0x10000);

          final node = Node(code, Type.code);
          node.code = rand.nextInt(0x10000);

          expect(node.code, equals(code));
          expect(node.type, equals(Type.code));
        });
      }
    });

    group('type label', () {
      for (var i = 0; i < 16; i++) {
        test('$i', () {
          final code = rand.nextInt(0x10000);
          final node = Node(code, Type.label);

          expect(node.code, equals(code));
          expect(node.type, equals(Type.label));
          {
            final code = rand.nextInt(0x10000);
            node.code = code;
            expect(node.code, equals(code));
            expect(node.type, equals(Type.code));
          }
        });
      }
    });
  });
}
