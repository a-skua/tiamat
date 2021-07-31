import 'core/error.dart';
import 'core/result.dart';
import 'core/node_tree.dart';
import 'core/symbol.dart';
import 'operand_parser.dart' as operand;

Result<List<int>> parse(final List<Symbol> s) {
  final tree = NodeTree();
  final errors = <Error>[];

  for (final symbol in s) {
    final error = operand.parse(symbol, tree);
    if (error != null) {
      errors.add(error);
    }
  }

  // labeling
  tree.labels.forEach((final name, final label) {
    final root = label.entity;
    if (root != null) {
      final index = tree.nodes.indexOf(root);
      for (final node in label.references) {
        node.code = index;
      }
    } else {
      errors.add(Error(
        '---\n'
        'label \'$name\' is not defined.',
        ErrorType.label,
      ));
      return;
    }
  });

  return Result(
    List.generate(
      tree.nodes.length,
      (i) => tree.nodes[i].code,
    ),
    errors,
  );
}
