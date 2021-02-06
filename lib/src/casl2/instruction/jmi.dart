import '../node/node.dart';
import 'automata/pattern2.dart';
import 'util.dart';

/// An instruction of CASL2, named JMI.
void jmi(final Root r, final Tree t) {
  final result = automata(r.operand.runes, 0x6100);

  // TODO: make error handling.
  assert(result.hasNotError);

  // |LABEL[EOF]
  // |`````^ label!
  // +
  // |LABEL,GR1[EOF]
  // |`````````^ index register!
  if (result.lastState == State.label ||
      (result.lastState == State.indexRegister && result.label.isNotEmpty)) {
    r.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    addReferenceLabel(result.label, r.nodes.last, t.labels);
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
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
    r.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }
}
