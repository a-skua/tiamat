import 'dart:math';

import 'package:tiamat/src/casl2/operand_parser/pop.dart';
import 'package:tiamat/src/casl2/core/node.dart';
import 'package:tiamat/src/casl2/core/node_tree.dart';
import 'package:tiamat/src/casl2/core/symbol.dart';
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

            final tree = NodeTree()
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
            final symbol = Symbol.fromString(
              comment: 'r',
              label: label,
              opecode: 'POP',
              operand: 'GR$register',
            );

            final baseLabelsLength = tree.labels.length;
            final baseNodesLength = tree.nodes.length;

            pop(symbol, tree);
            expect(symbol.nodes.length, equals(1));
            expect(tree.nodes.length, equals(baseNodesLength + 1));
            if (label.isEmpty) {
              expect(tree.labels.length, equals(baseLabelsLength));
              expect(tree.labels[label], equals(null));
            } else {
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], isNot(equals(null)));
              expect(tree.labels[label]?.entity, equals(symbol.nodes.first));
            }
            expect(symbol.nodes[0].code, equals(0x7100 | register << 4));
            expect(symbol.nodes[0].type, equals(Type.code));
          });
        }
      });
    });
  });
}
