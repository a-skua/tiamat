import 'core/tokenizer.dart';
import 'core/symbolizer.dart';
import 'core/node.dart';
import 'operand_parser.dart' as parser;

class Casl2 {
  List<int> compile(final String s) {
    return this.trans(this.parse(s));
  }

  Tree parse(final String s) {
    final tree = Tree();
    {
      final symbols = symbolize(tokenize(s));
      for (final symbol in symbols) {
        parser.parse(symbol, tree);
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
