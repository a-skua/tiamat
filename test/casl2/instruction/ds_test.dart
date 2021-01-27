import 'dart:math';

import 'package:tiamat/src/casl2/instruction/ds.dart';
import 'package:tiamat/src/casl2/node/node.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('ds', () {
    group('decimal', () {
      for (var i = 0; i < 8; i++) {
        test('$i', () {
          final size = rand.nextInt(100) + 1;
          final tree = Tree();
          final root = Root(
            comment: 'comment ${rand.nextInt(100)}',
            label: i % 2 > 0 ? 'L${rand.nextInt(100)}' : '',
            instruction: 'DS',
            operand: '${size}',
          );

          ds(root, tree);
          expect(root.nodes.length, equals(size));
          for (final node in root.nodes) {
            expect(node.type, equals(Type.code));
          }
          expect(tree.labels.length, equals(root.label.isNotEmpty ? 1 : 0));
          if (tree.labels.length == 1) {
            expect(tree.labels[root.label]?.entity, equals(root.nodes.first));
          }
        });
      }
    });
  });
}
