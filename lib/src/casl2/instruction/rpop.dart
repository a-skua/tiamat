import '../node/node.dart';
import 'pop.dart';
import 'util.dart';

/// A macro of CASL2, named RPOP.
void rpop(final Root r, final Tree t) {
  {
    final roots = <Root>[
      Root.simplified('POP', 'GR7'),
      Root.simplified('POP', 'GR6'),
      Root.simplified('POP', 'GR5'),
      Root.simplified('POP', 'GR4'),
      Root.simplified('POP', 'GR3'),
      Root.simplified('POP', 'GR2'),
      Root.simplified('POP', 'GR1'),
    ];
    for (final root in roots) {
      pop(root, t);
      r.nodes.addAll(root.nodes);
    }
  }

  if (r.label.isNotEmpty) {
    setLabel(r.label, r.nodes.first, t.labels);
  }
}
