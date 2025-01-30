import '../lexer/lexer.dart' show Token;

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
      _Statement(opecode, label: label, operand: operand);

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

/// Macro [Statement]
final class Macro implements Statement {
  @override
  final Token? label;

  @override
  final Token opecode;

  @override
  final List<Token> operand;

  Macro(
    this.opecode, {
    this.label,
    this.operand = const [],
  });

  @override
  String toString() {
    final stmt = <String>[
      if (label != null) label.toString(),
      opecode.toString(),
      if (operand.isNotEmpty) 'OPERAND(${operand.join(',')})',
    ];

    return 'MACRO(${stmt.join(',')})';
  }
}

/// Common [Statement]
final class _Statement extends Macro implements Statement {
  _Statement(super.opecode, {required super.label, required super.operand});

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

/// Subroutine [Statement]
final class Subroutine implements Statement {
  @override
  Token? get label => _startOp.label;

  @override
  Token get opecode => _startOp.opecode;

  @override
  List<Token> get operand => _startOp.operand;

  /// Start Statement
  ///
  /// ### example
  /// ```asm
  /// MAIN    START   FOO    ; StatementNode(START, label: MAIN operand: FOO)
  /// FOO     RET
  ///         END
  /// ```
  final Statement _startOp;

  final List<Statement> process;

  Subroutine(this._startOp, this.process);

  @override
  String toString() {
    final strs = [
      if (label != null) label.toString(),
      if (operand.isNotEmpty) 'START(${operand.join(',')})',
      if (process.isNotEmpty) 'PROCESS(${process.join(',')})',
    ];
    return 'SUBROUTINE(${strs.join(',')})';
  }
}
