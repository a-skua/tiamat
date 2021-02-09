import '../node/node.dart';
import 'push.dart';
import 'util.dart';

/// A macro of CASL2, named RPUSH.
void rpush(final Root r, final Tree t) {
  {
    final roots = <Root>[
      Root.simplified('PUSH', '0,GR1'),
      Root.simplified('PUSH', '0,GR2'),
      Root.simplified('PUSH', '0,GR3'),
      Root.simplified('PUSH', '0,GR4'),
      Root.simplified('PUSH', '0,GR5'),
      Root.simplified('PUSH', '0,GR6'),
      Root.simplified('PUSH', '0,GR7'),
    ];
    for (final root in roots) {
      push(root, t);
      r.nodes.addAll(root.nodes);
    }
  }

  if (r.label.isNotEmpty) {
    setLabel(r.label, r.nodes.first, t.labels);
  }
}
