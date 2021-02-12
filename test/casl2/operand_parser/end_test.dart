import 'dart:math';

import 'package:tiamat/src/casl2/operand_parser/end.dart';
import 'package:tiamat/src/casl2/core/node.dart';
import 'package:tiamat/src/casl2/core/symbol.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  test('end', () {
    final label = 'MAIN${rand.nextInt(100)}';
    final tree = Tree()..startLabel = label;
    final symbol = Symbol.fromString(
      comment: 'end test',
      label: '',
      opecode: 'END',
      operand: '',
    );

    end(symbol, tree);
    expect(tree.startLabel, equals(label));
    expect(tree.nodes.length, equals(0));
    expect(tree.labels.length, equals(0));
  });
}
