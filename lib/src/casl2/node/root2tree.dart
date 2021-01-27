import 'node.dart';
import '../instruction/instruction.dart';

/// Parse root nodes to node tree.
Tree root2tree(List<Root> roots) {
  final tree = Tree(roots);

  for (final root in roots) {
    switch (root.instruction) {
      case 'START':
        start(root, tree);
        break;
      case 'END':
        end(root, tree);
        break;
    }
  }

  return tree;
}
