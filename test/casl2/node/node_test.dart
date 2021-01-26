import 'dart:math';

import 'package:tiamat/src/casl2/node/node.dart';
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

  group('root node', () {
    for (var i = 0; i < 8; i++) {
      test('$i', () {
        final comment = 'c${rand.nextInt(0x100)}';
        final label = 'l${rand.nextInt(0x100)}';
        final instruction = 'i${rand.nextInt(0x100)}';
        final operand = 'o${rand.nextInt(0x100)}';

        final root = RootNode(
          comment: comment,
          label: label,
          instruction: instruction,
          operand: operand,
        );

        expect(root.comment, equals(comment));
        expect(root.label, equals(label));
        expect(root.instruction, equals(instruction));
        expect(root.operand, equals(operand));
        expect(root.children.length, equals(0));

        root.children.addAll(
          List.filled(8, Node(rand.nextInt(0x10000), Type.code)),
        );
        expect(root.children.length, equals(8));
      });
    }
  });
}
