import 'core/node_tree.dart';
import 'core/symbol.dart';
import 'operand_parser.dart' as operand;

List<int> parse(final List<Symbol> s) {
  final tree = NodeTree();
  for (final symbol in s) {
    operand.parse(symbol, tree);
  }

  // labeling
  for (final label in tree.labels.values) {
    assert(label.entity != null);

    final root = label.entity;
    if (root != null) {
      final index = tree.nodes.indexOf(root);
      for (final node in label.references) {
        node.code = index;
      }
    }
  }

  return List.generate(
    tree.nodes.length,
    (i) => tree.nodes[i].code,
  );
}
