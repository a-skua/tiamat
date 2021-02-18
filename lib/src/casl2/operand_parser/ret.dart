import '../core/error.dart';
import '../core/symbol.dart';
import '../core/node.dart';
import '../core/node_tree.dart';
import 'util.dart';

/// An instruction of CASL2, named RET.
Error? ret(final Symbol s, final NodeTree t) {
  if (s.operand.isNotEmpty) {
    return Error(
      'operand must be empty',
      ErrorType.operand,
    );
  }

  s.nodes.add(Node(0x8100));
  t.nodes.addAll(s.nodes);
  if (s.label.isNotEmpty) {
    setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
  }

  return null;
}
