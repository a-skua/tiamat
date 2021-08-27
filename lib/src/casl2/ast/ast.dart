import '../token/token.dart';

// Lang environment
class Env {
  int startPoint = 0;
  final labels = <String, Statement>{};
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

/// Statement's root
class Root implements Node {
  @override
  List<int> get code => [];

  @override
  int get size => 0;
}

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
  List<int> get code => _code.map((code) => code.value).toList(); // TODO

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
}

class StatementBlock implements Node {
  final List<Node> _statements;

  StatementBlock(this._statements);

  List<Node> get statements => List.from(_statements);

  @override
  List<int> get code => _getCode();

  List<int> _getCode() {
    final code = <int>[];
    for (final stmt in _statements) {
      code.addAll(stmt.code);
    }
    return code;
  }

  @override
  int get size => _size();

  int _size() {
    var size = 0;

    for (final stmt in statements) {
      size += stmt.size;
    }
    return size;
  }

  @override
  String toString() => 'BLOCK(${_statements.join(',')})';
}

/// error
class ErrorNode extends Node {
  final String _error;

  /// errors [start] position.
  final int start;

  /// errors [end] position.
  final int end;

  /// errors [lineStart] position.
  final int lineStart;

  /// errors [lineNumber].
  final int lineNumber;

  ErrorNode(
    this._error, {
    this.start = 0,
    this.end = 0,
    this.lineStart = 0,
    this.lineNumber = 1,
  });

  String get error => _error;

  @override
  List<int> get code => [];

  @override
  int get size => 0;
}

/// Parser return this Node
class Program extends StatementBlock {
  final Env env;
  Program(List<Node> nodes, this.env) : super(nodes);
}
