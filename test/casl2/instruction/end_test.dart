import 'dart:math';

import 'package:tiamat/src/casl2/instruction/end.dart';
import 'package:tiamat/src/casl2/node/node.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  test('end', () {
    final label = 'MAIN${rand.nextInt(100)}';
    final tree = Tree()..startLabel = label;
    final root = Root(
      comment: 'end test',
      label: '',
      instruction: 'END',
      operand: '',
    );

    end(root, tree);
    expect(tree.startLabel, equals(label));
    expect(tree.nodes.length, equals(0));
    expect(tree.labels.length, equals(0));
  });
}
