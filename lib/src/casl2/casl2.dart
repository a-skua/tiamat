import 'token/parser.dart' as token;
import 'node/token2root.dart';
import 'node/node.dart';
import 'instruction.dart';

class Casl2 {
  List<int> compile(final String s) {
    return this.trans(this.parse(s));
  }

  Tree parse(final String s) {
    final tree = Tree();
    {
      final roots = token2root(token.parse(s));
      for (final root in roots) {
        instruction(root, tree);
      }
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

    return tree;
  }

  List<int> trans(final Tree t) {
    return List.generate(t.nodes.length, (i) => t.nodes[i].code);
  }
}
