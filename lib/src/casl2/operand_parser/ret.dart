import '../core/symbol.dart';
import '../core/node.dart';
import 'util.dart';

/// An instruction of CASL2, named RET.
void ret(final Symbol s, final Tree t) {
  assert(s.operand.isEmpty);

  s.nodes.add(Node(0x8100));
  t.nodes.addAll(s.nodes);
  if (s.label.isNotEmpty) {
    setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
  }
}
