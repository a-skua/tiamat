import 'dart:math';

import 'package:tiamat/src/casl2/instruction/dc.dart';
import 'package:tiamat/src/casl2/node/node.dart';
import 'package:tiamat/src/util/charcode.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('dc', () {
    test('a string', () {
      final tree = Tree()
        ..labels.addAll({
          'foo': Label(),
          'bar': Label(),
        })
        ..nodes.addAll([
          Node(0),
          Node(0),
        ]);
      final root = Root(
        comment: 'string test',
        label: 'BUF',
        instruction: 'DC',
        operand: "'hello, world'",
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      dc(root, tree);
      expect(tree.nodes.length, equals(baseNodesLength + 12));
      expect(tree.labels.length, equals(baseLabelsLength + 1));
      expect(root.nodes.length, equals(12));

      final expecteds = 'hello, world'.split('');
      for (var i = 0; i < 12; i++) {
        expect(root.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(root.nodes[i].type, equals(Type.code));
        expect(root.nodes[i].code, equals(char2code[expecteds[i]]));
      }
      expect(tree.labels['BUF'], isNot(equals(null)));
      expect(tree.labels['BUF']?.entity, equals(root.nodes.first));
    });
  });
}
