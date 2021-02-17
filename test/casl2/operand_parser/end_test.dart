import 'dart:math';

import 'package:tiamat/src/casl2/operand_parser/end.dart';
import 'package:tiamat/src/casl2/core/node.dart';
import 'package:tiamat/src/casl2/core/node_tree.dart';
import 'package:tiamat/src/casl2/core/symbol.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('end', () {
    test('error', () {
      final tree = NodeTree();
      final symbol = Symbol.fromString(
        comment: 'end test',
        label: 'FOOO',
        opecode: 'END',
        operand: 'BAAR',
      );
      expect(end(symbol, tree), isNotNull);
    });

    test('success', () {
      final label = 'MAIN${rand.nextInt(100)}';
      final tree = NodeTree()..startLabel = label;
      final symbol = Symbol.fromString(
        comment: 'end test',
        label: '',
        opecode: 'END',
        operand: '',
      );

      expect(end(symbol, tree), isNull);
      expect(tree.startLabel, equals(label));
      expect(tree.nodes.length, equals(0));
      expect(tree.labels.length, equals(0));
    });
  });
}
