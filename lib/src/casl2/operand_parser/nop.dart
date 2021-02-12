import '../core/symbol.dart';
import '../core/node.dart';
import 'util.dart';

/// An instruction of CASL2, named NOP.
///
/// Do nuthing.
void nop(final Symbol s, final Tree t) {
  assert(s.operand.isEmpty);

  s.nodes.add(Node(0));
  t.nodes.addAll(s.nodes);
  if (s.label.isNotEmpty) {
    setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
  }
}
