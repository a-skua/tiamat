import '../node/node.dart';
import 'automata/pattern3.dart';
import 'util.dart';

/// An instruction of CASL2, named POP.
void pop(final Root r, final Tree t) {
  final result = automata(r.operand.runes, 0x7100);

  // TODO: make error handling.
  assert(result.hasNotError);

  r.nodes.addAll(result.values);
  t.nodes.addAll(result.values);
  if (r.label.isNotEmpty) {
    setLabel(r.label, r.nodes.first, t.labels);
  }
}
