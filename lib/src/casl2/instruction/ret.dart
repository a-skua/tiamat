import '../node/node.dart';
import 'util.dart';

/// An instruction of CASL2, named RET.
void ret(final Root r, final Tree t) {
  assert(r.operand.isEmpty);

  r.nodes.add(Node(0x8100));
  t.nodes.addAll(r.nodes);
  if (r.label.isNotEmpty) {
    setLabel(r.label, r.nodes.first, t.labels);
  }
}
