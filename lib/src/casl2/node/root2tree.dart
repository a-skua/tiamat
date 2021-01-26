import 'node.dart';

/// Parse root nodes to node tree.
Tree root2tree(List<Root> roots) {
  final tree = Tree(roots);

  for (final root in roots) {
    switch (root.instruction) {
      case 'START':
        break;
    }
  }

  return tree;
}
