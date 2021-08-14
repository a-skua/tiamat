class Node {}

class Satement extends Node {}

class BlockStatement extends Statement {
  final List<Statement> _statements = [];
}

class Program extends BlockStatement {}
