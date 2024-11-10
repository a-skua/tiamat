import '../token/token.dart';
import '../typedef.dart';

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

//// Error of Parser
class ParseError {
  final String message;
  final int start;
  final int end;
  final int lineStart;
  final int lineNumber;

  ParseError(
    this.message, {
    required this.start,
    required this.end,
    required this.lineStart,
    required this.lineNumber,
  });

  @override
  String toString() => 'L$lineNumber: $message';
}

/// Parser of Code
typedef Parser = Result<List<Code>, ParseError> Function(
    Node? prev, Token? label, Token opecode, List<Token> operand);

// Node of CASL2
abstract class Node {
  Result<List<Code>, ParseError> get code;
  Size get size;
  Position get position;
  @override
  String toString();
}

/// Statement Node
abstract class StatementNode implements Node {
  Label? get label;
  Opecode? get opecode;

  factory StatementNode(StatementNode? prev, Token? label, Token opecode,
          List<Token> operand, Parser parser) =>
      _StatementNode(
        prev,
        label,
        opecode,
        operand,
        parser,
      );
}

/// Impl Statement Node
final class _StatementNode implements StatementNode {
  final StatementNode? _prev;
  final Token? _label;
  final Token _opecode;
  final List<Token> _operand;
  final Parser _parse;

  _StatementNode(
    this._prev,
    this._label,
    this._opecode,
    this._operand,
    this._parse,
  );

  @override
  Label? get label => _label?.runesAsString;

  @override
  Opecode? get opecode => _opecode.runesAsString;

  @override
  Result<List<Code>, ParseError> get code =>
      _parse(_prev, _label, _opecode, _operand);

  @override
  Size get size => code.isOk ? code.ok.length : 0;

  @override
  Position get position => (_prev?.position ?? 0) + (_prev?.size ?? 0);

  @override
  String toString() {
    final stmt = <String>[
      if (_label != null) _label.toString(),
      _opecode.toString(),
      if (_operand.isNotEmpty) 'OPERAND(${_operand.join(',')})',
    ];

    return 'STATEMENT(${stmt.join(',')})';
  }
}

/// Macro Node
final class MacroNode extends _StatementNode {
  MacroNode(StatementNode? prev, Token? label, Token opecode,
      List<Token> operand, Parser parser)
      : super(
          prev,
          label,
          opecode,
          operand,
          parser,
        );

  @override
  Label? get label => _label?.runesAsString;

  @override
  Opecode? get opecode => _opecode.runesAsString;

  @override
  String toString() {
    final strs = <String>[
      if (_label != null) _label.toString(),
      _opecode.toString(),
      if (_operand.isNotEmpty) 'OPERAND(${_operand.join(',')})',
    ];
    return 'MACRO(${strs.join(',')})';
  }
}

/// Block Node
abstract class _BlockNode implements Node {
  final List<StatementNode> _nodeList;

  _BlockNode(this._nodeList);

  @override
  Result<List<Code>, ParseError> get code =>
      _nodeList.map((node) => node.code).reduce((a, b) {
        if (a.isError) return a;
        if (b.isError) return b;

        a.ok.addAll(b.ok);
        return a;
      });

  @override
  Size get size => _nodeList.map((node) => node.size).reduce((a, b) => a + b);

  @override
  Position get position => _nodeList.first.position;
}

/// Subroutine Node
final class SubroutineNode extends _BlockNode implements StatementNode {
  final Token? _label;

  final Token? _start;
  SubroutineNode(this._label, this._start, List<StatementNode> nodeList)
      : super(nodeList);

  @override
  Label? get label => _label?.runesAsString;

  @override
  Opecode? get opecode => null;

  @override
  Position get position => _start != null
      ? _nodeList.firstWhere((node) {
          final label = node.label;
          final start = _start;
          return label != null && start != null && label == start.runesAsString;
        }).position
      : super.position;

  @override
  String toString() {
    final strs = [
      if (_label != null) _label.toString(),
      if (_start != null) 'START(${_start.toString()})',
      if (_nodeList.isNotEmpty) 'PROCESS(${_nodeList.join(',')})',
    ];
    return 'SUBROUTINE(${strs.join(',')})';
  }
}

/// Module Node
final class ModuleNode extends _BlockNode {
  ModuleNode(nodeList) : super(nodeList);

  List<Label> get labels =>
      _nodeList.map((node) => node.label).whereType<Label>().toList();

  @override
  String toString() => 'MODULE(${_nodeList.join(',')})';
}