import '../token/token.dart';

/// Label of CASL2
typedef Label = String;

/// Opecode of CASL2
typedef Opecode = String;

/// Code of COMET2
class Code {
  final int Function(Position) _value;

  Code(this._value);

  int value([Position base = 0]) => _value(base);
}

/// Size of Node
typedef Size = int;

/// Position of Memory on COMET2
typedef Position = int;

// Node of CASL2
abstract class Node {
  @override
  String toString();

  factory Node.statement(
    Token opecode, {
    Token? label,
    List<Token> operand = const [],
  }) =>
      _StatementNode(label, opecode, operand);

  factory Node.macro(
    Token opecode, {
    Token? label,
    List<Token> operand = const [],
  }) =>
      MacroNode(opecode, label: label, operand: operand);

  factory Node.module(List<StatementNode> stmtList) => ModuleNode(stmtList);
}

/// Statement Node
abstract class StatementNode implements Node {
  Token? get label;
  Token get opecode;
  List<Token> get operand;

  factory StatementNode(
    Token opecode, {
    Token? label,
    List<Token> operand = const [],
  }) =>
      _StatementNode(label, opecode, operand);

  factory StatementNode.macro(
    Token opecode, {
    Token? label,
    List<Token> operand = const [],
  }) =>
      MacroNode(opecode, label: label, operand: operand);

  factory StatementNode.subroutine(
    StatementNode startOp, {
    List<StatementNode> process = const [],
  }) =>
      SubroutineNode(startOp, process);
}

/// Impl Statement Node
final class _StatementNode implements StatementNode {
  @override
  final Token? label;

  @override
  final Token opecode;

  @override
  final List<Token> operand;

  _StatementNode(this.label, this.opecode, this.operand);

  @override
  String toString() {
    final stmt = <String>[
      if (label != null) label.toString(),
      opecode.toString(),
      if (operand.isNotEmpty) 'OPERAND(${operand.join(',')})',
    ];

    return 'STATEMENT(${stmt.join(',')})';
  }
}

/// Macro Node
final class MacroNode extends _StatementNode {
  MacroNode(Token opecode, {Token? label, List<Token> operand = const []})
      : super(label, opecode, operand);

  @override
  String toString() {
    final strs = <String>[
      if (label != null) label.toString(),
      opecode.toString(),
      if (operand.isNotEmpty) 'OPERAND(${operand.join(',')})',
    ];
    return 'MACRO(${strs.join(',')})';
  }
}

/// Block Node
abstract class _BlockNode implements Node {
  final List<StatementNode> _stmtList;

  _BlockNode(this._stmtList);
}

/// Subroutine Node
final class SubroutineNode extends _BlockNode implements StatementNode {
  @override
  Token? get label => _startOp.label;

  @override
  Token get opecode => _startOp.opecode;

  @override
  List<Token> get operand => _startOp.operand;

  /// Start Opecode
  ///
  /// ### example
  /// ```asm
  /// MAIN    START   FOO    ; StatementNode(START, label=MAIN operand=FOO)
  /// FOO     RET
  ///         END
  /// ```
  final StatementNode _startOp;

  SubroutineNode(this._startOp, List<StatementNode> proc) : super(proc);

  @override
  String toString() {
    final strs = [
      if (label != null) label.toString(),
      if (operand.isNotEmpty) 'START(${operand.join(',')})',
      if (_stmtList.isNotEmpty) 'PROCESS(${_stmtList.join(',')})',
    ];
    return 'SUBROUTINE(${strs.join(',')})';
  }
}

/// Module Node
final class ModuleNode extends _BlockNode implements Node {
  ModuleNode(List<StatementNode> stmtList) : super(stmtList);

  @override
  String toString() {
    return 'MODULE(${_stmtList.join(',')})';
  }
}