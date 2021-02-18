import '../core/error.dart';
import '../core/symbol.dart';
import '../core/node_tree.dart';
import 'automata/pattern1.dart';
import 'util.dart';

/// An instruction of CASL2, named ST.
Error? st(final Symbol s, final NodeTree t) {
  final result = automata(s.operand, 0x1100);

  if (result.hasError) {
    return result.error;
  }

  if (result.lastState == State.register2) {
    return Error(
      'syntax error',
      ErrorType.operand,
    );
  }

  // |GR0,123[EOF]
  // |```````^ address!
  if (result.lastState == State.address) {
    s.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    if (s.label.isNotEmpty) {
      setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
    }
    return null;
  }

  // |GR0,#FFFF[EOF]
  // |`````````^ hex address!
  if (result.lastState == State.hexAddress) {
    s.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    if (s.label.isNotEmpty) {
      setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
    }
    return null;
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
    return null;
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
    return null;
  }

  // |GR0,0,GR1[EOF]
  // |`````````^ index with address!
  if (result.lastState == State.indexRegister) {
    s.nodes.addAll(result.values);
    t.nodes.addAll(result.values);
    if (s.label.isNotEmpty) {
      setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
    }
    return null;
  }

  return null;
}
