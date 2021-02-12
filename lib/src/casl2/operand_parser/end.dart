import '../core/symbol.dart';
import '../core/node_tree.dart';
import 'util.dart';

/// An instruction of CASL2, named END.
///
/// Do nothing.
void end(final Symbol s, final NodeTree t) {
  assert(s.label.isEmpty);
  assert(s.operand.isEmpty);
  return;
}
