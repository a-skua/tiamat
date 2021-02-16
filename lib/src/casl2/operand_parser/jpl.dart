import '../core/symbol.dart';
import '../core/node_tree.dart';
import 'automata/pattern2.dart';
import 'util.dart';

/// An instruction of CASL2, named JPL.
void jpl(final Symbol s, final NodeTree t) {
  final result = automata(s.operand, 0x6500);

  // TODO: make error handling.
  assert(result.hasNotError);

  // |LABEL[EOF]
  // |`````^ label!
  // +
  // |LABEL,GR1[EOF]
  // |`````````^ index register!
  if (result.lastState == State.label ||
      (result.lastState == State.indexRegister && result.label.isNotEmpty)) {
    s.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    addReferenceLabel(result.label, s.nodes.last, t.labels);
    if (s.label.isNotEmpty) {
      setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
    }
    return;
  }

  // |#FF16[EOF]
  // |`````^ hex address!
  // +
  // |12345[EOF]
  // |`````^ address!
  // +
  // |1,GR1[EOF]
  // |`````^ index register!
  if (result.lastState == State.hexAddress ||
      result.lastState == State.address ||
      result.lastState == State.indexRegister) {
    s.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    if (s.label.isNotEmpty) {
      setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
    }
    return;
  }
}