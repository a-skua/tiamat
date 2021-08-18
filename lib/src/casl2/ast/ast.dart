import '../token/token.dart';

abstract class Node {
  List<int> toCode();
}

class Statement implements Node {
  final Token? label;
  final Token opecode;
  final List<Token> _operand;
  List<Token> get operand => List.from(_operand);

  Statement(
    this.opecode,
    this._operand, {
    this.label,
  });

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

class Root extends StatementBlock {
  Root(List<Node> nodes) : super(nodes);
}
