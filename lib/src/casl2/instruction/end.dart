import '../node/node.dart';
import 'util.dart';

/// An instruction of CASL2, named END.
///
/// Do nothing.
void end(final Root r, final Tree t) {
  assert(r.label.isEmpty);
  assert(r.operand.isEmpty);
  return;
}
