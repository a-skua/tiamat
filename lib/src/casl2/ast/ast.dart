import '../token/token.dart';

abstract class Node {
  List<int> toCode();
}

/// Statement's root
class Root implements Node {
  List<int> toCode() => [];
}

class Statement implements Node {
  final Node _parent;
  final Token? label;
  final Token opecode;
  final List<Token> _operand;
  List<Token> get operand => List.from(_operand);

  Statement(
    this._parent,
    this.opecode,
    this._operand, {
    this.label,
  });

  int getPosition() {
    if (_parent is Root) {
      return toCode().length;
    } else if (_parent is Statement) {
      return toCode().length + (_parent as Statement).getPosition();
    } else {
      return 0;
    }
  }

  @override
  List<int> toCode() => []; // TODO

  @override
  String toString() {
    final operand =
        List<String>.generate(_operand.length, (i) => _operand[i].toString());

    final stmt = <String>[
      if (label != null) label.toString(),
      opecode.toString(),
      if (operand.isNotEmpty) 'OPERAND(${operand.join(',')})',
    ];

    return 'STATEMENT(${stmt.join(',')})';
  }
}

class StatementBlock implements Node {
  final List<Node> _statements;

  StatementBlock(this._statements);

  @override
  List<int> toCode() => []; // TODO

  @override
  String toString() => 'BLOCK(${_statements.join(',')})';
}

/// Parser return this Node
class Program extends StatementBlock {
  Program(List<Node> nodes) : super(nodes);
}
