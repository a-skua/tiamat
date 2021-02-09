import '../node/node.dart';
import 'automata/pattern4.dart';
import 'util.dart';
import 'push.dart';
import 'lad.dart';
import 'svc.dart';
import 'pop.dart';

/// A macro of CASL2, named IN.
void input(final Root r, final Tree t) {
  final result = automata(r.operand.runes);

  // TODO: make error handling.
  assert(result.hasNotError);

  // |BUF,255[EOF]
  // |```````^ length!
  // +
  // |BUF,#00FF[EOF]
  // |`````````^ hex length!
  // +
  // |128,255[EOF]
  // |```````^ length!
  // +
  // |#0100,#00FF[EOF]
  // |```````````^ hex length!
  {
    final roots = <Root>[
      Root.simplified('PUSH', '0,GR1'),
      Root.simplified('PUSH', '0,GR2'),
      if (result.label != null) Root.simplified('LAD', 'GR1,${result.label}'),
      if (result.address != null)
        Root.simplified('LAD', 'GR1,${result.address}'),
      Root.simplified('LAD', 'GR2,${result.length}'),
      Root.simplified('SVC', '1'),
      Root.simplified('POP', 'GR2'),
      Root.simplified('POP', 'GR1'),
    ];
    for (final root in roots) {
      switch (root.instruction) {
        case 'PUSH':
          push(root, t);
          break;
        case 'LAD':
          lad(root, t);
          break;
        case 'SVC':
          svc(root, t);
          break;
        case 'POP':
          pop(root, t);
          break;
      }
      r.nodes.addAll(root.nodes);
    }
  }
  if (r.label.isNotEmpty) {
    setLabel(r.label, r.nodes.first, t.labels);
  }
}
