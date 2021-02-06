import 'dart:math';

import 'package:tiamat/src/casl2/instruction/pop.dart';
import 'package:tiamat/src/casl2/node/node.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('pop', () {
    group('r', () {
      group('address with index', () {
        for (var i = 0; i < 16; i++) {
          test('$i', () {
            final label = i % 2 > 0 ? 'LABEL' : '';
            final register = rand.nextInt(8);

            final tree = Tree()
              ..nodes.addAll(List.generate(
                rand.nextInt(0x100),
                (i) => Node(i),
              ));
            {
              final length = rand.nextInt(0x100);
              tree.labels.addAll(Map.fromIterables(
                List.generate(length, (i) => '$i${rand.nextInt(0x10000)}'),
                List.generate(length, (_) => Label()),
              ));
            }
            final root = Root(
              comment: 'r',
              label: label,
              instruction: 'POP',
              operand: 'GR$register',
            );

            final baseLabelsLength = tree.labels.length;
            final baseNodesLength = tree.nodes.length;

            pop(root, tree);
            expect(root.nodes.length, equals(1));
            expect(tree.nodes.length, equals(baseNodesLength + 1));
            if (label.isEmpty) {
              expect(tree.labels.length, equals(baseLabelsLength));
              expect(tree.labels[label], equals(null));
            } else {
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], isNot(equals(null)));
              expect(tree.labels[label]?.entity, equals(root.nodes.first));
            }
            expect(root.nodes[0].code, equals(0x7100 | register));
            expect(root.nodes[0].type, equals(Type.code));
          });
        }
      });
    });
  });
}
