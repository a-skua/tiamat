abstract class Node {}

class Statement implements Node {
  final String label;
  final String opecode;
  final List<Node> _operand;

  Statement(
    this.opecode,
    this._operand, {
    this.label = '',
  });
}

class StatementBlock implements Node {
  final List<Statement> _statements;

  StatementBlock(this._statements);
}

class Root extends StatementBlock {
  Root() : super([]);
}
