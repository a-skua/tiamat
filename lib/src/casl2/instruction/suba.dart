import '../node/node.dart';
import 'automata/pattern1.dart';
import 'util.dart';

/// An instruction of CASL2, named SUBA.
void suba(final Root r, final Tree t) {
  final result = automata(r.operand.runes, 0x2100, 0x2500);

  // TODO: make error handling.
  assert(result.hasNotError);

  // |GR0,123[EOF]
  // |```````^ address!
  if (result.lastState == State.address) {
    r.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }

  // |GR0,#FFFF[EOF]
  // |`````````^ hex address!
  if (result.lastState == State.hexAddress) {
    r.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }

  // |GR1,LABEL[EOF]
  // |`````````^ label!
  if (result.lastState == State.label) {
    r.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    addReferenceLabel(result.label, r.nodes.last, t.labels);
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }

  // |GR0,GR1[EOF]
  // |```````^ register2!
  if (result.lastState == State.register2) {
    r.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }

  // |GR0,LABEL,GR1[EOF]
  // |`````````````^ index with label!
  if (result.lastState == State.indexRegister && result.label.isNotEmpty) {
    r.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    addReferenceLabel(result.label, r.nodes.last, t.labels);
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }

  // |GR0,0,GR1[EOF]
  // |`````````^ index with address!
  if (result.lastState == State.indexRegister) {
    r.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }
}
