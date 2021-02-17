import '../core/error.dart';
import '../core/symbol.dart';
import '../core/node_tree.dart';
import 'automata/pattern6.dart';
import 'util.dart';

/// An instruction of CASL2, named DS.
///
/// To ensure word space.
Error? ds(final Symbol s, final NodeTree t) {
  final result = automata(s.operand);

  if (result.hasError) {
    return result.error;
  }

  s.nodes.addAll(result.values);
  t.nodes.addAll(result.values);
  if (s.label.isNotEmpty) {
    setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
  }
  return null;
}
