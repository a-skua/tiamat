import 'dart:math';

import 'package:tiamat/src/casl2/instruction/ret.dart';
import 'package:tiamat/src/casl2/node/node.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('ret', () {
    group('with label', () {
      for (var i = 0; i < 4; i++) {
        test('$i', () {
          final label = 'LABEL$i';

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
            comment: 'ret test with label $i',
            label: label,
            instruction: 'RET',
            operand: '',
          );

          final baseLabelsLength = tree.labels.length;
          final baseNodesLength = tree.nodes.length;

          ret(root, tree);
          expect(tree.nodes.length, equals(baseNodesLength + 1));
          expect(tree.labels.length, equals(baseLabelsLength + 1));
          expect(root.nodes.length, equals(1));

          expect(root.nodes.first, equals(tree.nodes.last));
          expect(root.nodes.first.type, equals(Type.code));
          expect(root.nodes.first.code, equals(0x8100));
          expect(tree.labels[label], isNot(equals(null)));
          expect(tree.labels[label]?.entity, equals(root.nodes.first));
        });
      }
    });

    group('without label', () {
      for (var i = 0; i < 4; i++) {
        test('$i', () {
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
            comment: 'ret test with label $i',
            label: '',
            instruction: 'RET',
            operand: '',
          );

          final baseLabelsLength = tree.labels.length;
          final baseNodesLength = tree.nodes.length;

          ret(root, tree);
          expect(tree.nodes.length, equals(baseNodesLength + 1));
          expect(tree.labels.length, equals(baseLabelsLength));
          expect(root.nodes.length, equals(1));

          expect(root.nodes.first, equals(tree.nodes.last));
          expect(root.nodes.first.type, equals(Type.code));
          expect(root.nodes.first.code, equals(0x8100));
        });
      }
    });
  });
}
