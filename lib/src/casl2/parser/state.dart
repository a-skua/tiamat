import '../ast/ast.dart';

// State of parser
class State {
  /// Parent Env
  State? _parent;

  /// labels
  final _labels = <Label, StatementNode>{};

  StatementNode? getLabel(Label name) =>
      _labels[name] ?? _parent?.getLabel(name);

  void setLabel(StatementNode stmt) {
    if (stmt.label != null) _labels[stmt.label as Label] = stmt;
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
