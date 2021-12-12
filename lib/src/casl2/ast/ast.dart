import '../token/token.dart';

// Lang environment
class Env {
  int startPoint = 100;
  String entryLabel = 'MAIN';
  final labels = <String, Statement>{};

  int get entryPoint => labels[entryLabel]?.position ?? startPoint;
}

abstract class Code {
  int get value;

  @override
  String toString() => '$value';
}

class LiteralCode implements Code {
  final int _value;
  const LiteralCode(this._value);

  @override
  int get value => _value;
}

class LabelCode implements Code {
  final String _label;
  final int _base;
  final Env _env;

  const LabelCode(this._label, this._base, this._env);

  @override
  int get value => _getValue();

  int _getValue() {
    final stmt = _env.labels[_label];
    if (stmt == null) {
      return _base + _env.startPoint;
    } else {
      return stmt.position + _base + _env.startPoint;
    }
  }
}

abstract class Node {
  List<int> get code;

  int get size;
}

/// Empty node.
class Empty implements Node {
  @override
  List<int> get code => [];

  @override
  int get size => 0;
}

/// Root merger node.
class Root extends Empty {}

/// End marker node.
class End extends Empty {}

class Statement implements Node {
  final Node _parent;
  late final Token? _label;
  final Token _opecode;
  final List<Token> _operand;
  late final List<Code> _code; // TODO!

  Statement(
    this._parent,
    this._opecode,
    this._operand, {
    Token? label,
    List<Code>? code,
  }) {
    _label = label;

    if (code == null) {
      _code = [];
    } else {
      _code = code;
    }
  }

  String get label => _label?.runesAsString ?? '';

  String get opecode => _opecode.runesAsString;

  String get operand => _operand.map((token) => token.runesAsString).join(',');

  int get position => _getPosition();

  int _getPosition() {
    final parent = _parent;
    if (parent is Statement) {
      return parent.position + parent.size;
    } else {
      return 0;
    }
  }

  @override
  List<int> get code => _code.map((code) => code.value).toList();

  @override
  int get size => _code.length;

  @override
  String toString() {
    // final operand =
    //     List<String>.generate(_operand.length, (i) => _operand[i].toString());

    final stmt = <String>[
      if (_label != null) _label.toString(),
      _opecode.toString(),
      if (_operand.isNotEmpty) 'OPERAND(${_operand.join(',')})',
    ];

    return 'STATEMENT(${stmt.join(',')})';
  }

  String toStringWithIndent({final prefix = ''}) {
    const indent = '    ';
    final stmt = <String>[
      if (_label != null) _label.toString(),
      _opecode.toString(),
      if (_operand.isNotEmpty)
        'OPERAND(\n'
            '${_operand.map((final str) => '$prefix$indent$indent$str').join(',\n')}\n'
            '$prefix$indent)',
    ];

    return '${prefix}STATEMENT(\n'
        '${stmt.map((final str) => '$prefix$indent$str').join(',\n')}\n'
        '$prefix)';
  }
}

class BlockStatement extends Statement {
  final List<Statement> _statements;

  BlockStatement(this._statements,
      {required Node parent,
      required Token opecode,
      required List<Token> operand,
      Token? label})
      : super(parent, opecode, operand, label: label);

  factory BlockStatement.onlyStatements(final List<Statement> stmts) {
    return BlockStatement(
      stmts,
      parent: Root(),
      opecode: Token(''.runes, TokenType.opecode),
      operand: [],
    );
  }

  @override
  String get label => _getLabel();

  String _getLabel() {
    for (final stmt in _statements) {
      if (stmt.label.isNotEmpty) {
        return stmt.label;
      }
    }
    return '';
  }

  List<Node> get statements => List.from(_statements);

  @override
  List<int> get code =>
      _statements.map((stmt) => stmt.code).reduce((all, code) {
        all.addAll(code);
        return all;
      });

  @override
  int get size =>
      _statements.map((stmt) => stmt.size).reduce((sum, size) => sum + size);

  @override
  String toString() => 'BLOCK(${_statements.join(',')})';

  @override
  String toStringWithIndent({final prefix = ''}) {
    const indent = '    ';
    return '${prefix}BLOCK(\n'
        '${_statements.map((stmt) => stmt.toStringWithIndent(prefix: '$prefix$indent')).join(',\n')}\n'
        '$prefix)';
  }
}

/// error
class ErrorNode extends Node {
  final String error;

  /// errors [start] position.
  final int start;

  /// errors [end] position.
  final int end;

  /// errors [lineStart] position.
  final int lineStart;

  /// errors [lineNumber].
  final int lineNumber;

  ErrorNode(
    this.error, {
    this.start = 0,
    this.end = 0,
    this.lineStart = 0,
    this.lineNumber = 1,
  });

  @override
  List<int> get code => [];

  @override
  int get size => 0;

  @override
  String toString() {
    return '(line $lineNumber) $error';
  }
}
