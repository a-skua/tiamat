import '../core/error.dart';
import '../core/symbol.dart';
import '../core/node_tree.dart';
import 'automata/pattern5.dart';
import 'util.dart';

/// An instruction of CASL2, named DC.
///
/// To define constants.
Error? dc(final Symbol s, final NodeTree t) {
  final result = automata(s.operand);

  if (result.hasError) {
    return result.error;
  }

  s.nodes.addAll(result.values);
  t.nodes.addAll(result.values);
  result.labels.forEach((label, node) => addReferenceLabel(
        label,
        node,
        t.labels,
      ));
  if (s.label.isNotEmpty) {
    setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
  }
  return null;
}
