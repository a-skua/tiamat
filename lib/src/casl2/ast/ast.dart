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

/// Statement Node
abstract class Statement {
  Token? get label;
  Token get opecode;
  List<Token> get operand;

  factory Statement(
    Token opecode, {
    Token? label,
    List<Token> operand = const [],
  }) =>
      _Statement(label, opecode, operand);

  factory Statement.macro(
    Token opecode, {
    Token? label,
    List<Token> operand = const [],
  }) =>
      Macro(opecode, label: label, operand: operand);

  factory Statement.subroutine(
    Statement startOp, {
    List<Statement> process = const [],
  }) =>
      Subroutine(startOp, process);
}

/// Impl Statement Node
final class _Statement implements Statement {
  @override
  final Token? label;

  @override
  final Token opecode;

  @override
  final List<Token> operand;

  _Statement(this.label, this.opecode, this.operand);

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
final class Macro extends _Statement {
  Macro(Token opecode, {Token? label, List<Token> operand = const []})
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
abstract class _Block {
  final List<Statement> _stmtList;

  _Block(this._stmtList);
}

/// Subroutine Node
final class Subroutine extends _Block implements Statement {
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
  final Statement _startOp;

  Subroutine(this._startOp, List<Statement> proc) : super(proc);

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
final class Module extends _Block {
  Module(List<Statement> stmtList) : super(stmtList);

  @override
  String toString() {
    return 'MODULE(${_stmtList.join(',')})';
  }
}