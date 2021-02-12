import '../core/symbol.dart';
import '../core/node.dart';
import 'automata/pattern1.dart';
import 'util.dart';

/// An instruction of CASL2, named SLA.
void sla(final Symbol s, final Tree t) {
  final result = automata(s.operand, 0x5000);

  // TODO: make error handling.
  assert(result.hasNotError);
  assert(result != State.register2);

  // |GR0,123[EOF]
  // |```````^ address!
  if (result.lastState == State.address) {
    s.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    if (s.label.isNotEmpty) {
      setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
    }
    return;
  }

  // |GR0,#FFFF[EOF]
  // |`````````^ hex address!
  if (result.lastState == State.hexAddress) {
    s.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    if (s.label.isNotEmpty) {
      setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
    }
    return;
  }

  // |GR1,LABEL[EOF]
  // |`````````^ label!
  if (result.lastState == State.label) {
    s.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    addReferenceLabel(result.label, s.nodes.last, t.labels);
    if (s.label.isNotEmpty) {
      setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
    }
    return;
  }

  // |GR0,LABEL,GR1[EOF]
  // |`````````````^ index with label!
  if (result.lastState == State.indexRegister && result.label.isNotEmpty) {
    s.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    addReferenceLabel(result.label, s.nodes.last, t.labels);
    if (s.label.isNotEmpty) {
      setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
    }
    return;
  }

  // |GR0,0,GR1[EOF]
  // |`````````^ index with address!
  if (result.lastState == State.indexRegister) {
    s.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    if (s.label.isNotEmpty) {
      setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
    }
    return;
  }
}
