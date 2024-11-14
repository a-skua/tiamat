import '../parser/ast.dart';

// State of parser
final class State {
  /// Parent Env
  State? _parent;

  /// labels
  final _labels = <Label, Statement>{};

  Statement? getLabel(Label name) => _labels[name] ?? _parent?.getLabel(name);

  void setLabel(Statement stmt) {
    final label = stmt.label;
    if (label != null) _labels[String.fromCharCodes(label.runes)] = stmt;
  }

  State();

  factory State.block(State parent) {
    return State().._parent = parent;
  }

  @override
  String toString() {
    final str = <String>[];
    _parent?._labels.forEach((k, v) => str.add(k));
    _labels.forEach((k, v) => str.add(k));

    return 'State(${str.join(',')})';
  }
}
