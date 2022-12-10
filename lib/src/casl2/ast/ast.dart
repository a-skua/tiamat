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
    Node? parent, Token? label, Token opecode, List<Token> operand);

// Node of CASL2
abstract class Node {
  Label? get label;
  Opecode? get opecode;
  Result<List<Code>, ParseError> get code;
  Size get size;
  Position get position;
}

class _Empty implements Node {
  final Node? _parent;

  _Empty(this._parent);

  @override
  Label? get label => null;

  @override
  Opecode? get opecode => null;

  @override
  Result<List<Code>, ParseError> get code => Result.ok([]);

  @override
  Size get size => 0;

  @override
  Position get position => (_parent?.position ?? 0) + (_parent?.size ?? 0);

  @override
  String toString() => '()';
}

/// End of Node
class EndNode extends _Empty {
  EndNode(Node? parent) : super(parent);
}

/// Statement of CASL2.
class StatementNode implements Node {
  final Node? _parent;
  final Token? _label;
  final Token _opecode;
  final List<Token> _operand;
  final Parser _parser;

  StatementNode(
    this._parent,
    this._label,
    this._opecode,
    this._operand,
    this._parser,
  );

  @override
  Label? get label => _label?.runesAsString;

  @override
  Opecode? get opecode => _opecode.runesAsString;

  @override
  Result<List<Code>, ParseError> get code =>
      _parser(_parent, _label, _opecode, _operand);

  @override
  Size get size => code.isOk ? code.ok.length : 0;

  @override
  Position get position => (_parent?.position ?? 0) + (_parent?.size ?? 0);

  @override
  String toString() {
    final stmt = <String>[
      if (label != null) 'LABEL($label)',
      _opecode.toString(),
      if (_operand.isNotEmpty) 'OPERAND(${_operand.join(',')})',
    ];

    return 'STATEMENT(${stmt.join(',')})';
  }
}

/// Block Node
class BlockNode implements Node {
  final List<Node> _nodeList;

  BlockNode(this._nodeList);

  @override
  Label? get label => _nodeList.first.label;

  @override
  Opecode? get opecode => _nodeList.first.label;

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

  @override
  String toString() => 'BLOCK(${_nodeList.join(',')})';
}
