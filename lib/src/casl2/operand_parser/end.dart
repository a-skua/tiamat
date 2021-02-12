import '../core/symbol.dart';
import '../core/node.dart';
import 'util.dart';

/// An instruction of CASL2, named END.
///
/// Do nothing.
void end(final Symbol s, final Tree t) {
  assert(s.label.isEmpty);
  assert(s.operand.isEmpty);
  return;
}
