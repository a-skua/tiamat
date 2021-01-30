import '../node/node.dart';
import 'util.dart';

/// An instruction of CASL2, named NOP.
///
/// Do nuthing.
void nop(final Root r, final Tree t) {
  assert(r.operand.isEmpty);

  r.nodes.add(Node(0));
  t.nodes.addAll(r.nodes);
  if (r.label.isNotEmpty) {
    setLabel(r.label, r.nodes.first, t.labels);
  }
}
