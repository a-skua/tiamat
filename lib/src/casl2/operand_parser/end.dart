import '../core/error.dart';
import '../core/symbol.dart';
import '../core/node_tree.dart';
import 'util.dart';

/// An instruction of CASL2, named END.
///
/// Do nothing.
Error? end(final Symbol s, final NodeTree t) {
  if (s.operand.isNotEmpty) {
    return Error('syntax error', ErrorType.operand);
  }

  if (s.label.isNotEmpty) {
    return Error('syntax error', ErrorType.label);
  }

  return null;
}
