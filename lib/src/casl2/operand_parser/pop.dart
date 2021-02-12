import '../core/symbol.dart';
import '../core/node.dart';
import 'automata/pattern3.dart';
import 'util.dart';

/// An instruction of CASL2, named POP.
void pop(final Symbol s, final Tree t) {
  final result = automata(s.operand, 0x7100);

  // TODO: make error handling.
  assert(result.hasNotError);

  s.nodes.addAll(result.values);
  t.nodes.addAll(result.values);
  if (s.label.isNotEmpty) {
    setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
  }
}
