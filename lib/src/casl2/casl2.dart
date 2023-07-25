import './lexer/lexer.dart';
import './ast/ast.dart' hide Parser;
import './parser/parser.dart';

/// CASL2 instance.
class Casl2 {
  final _state = State();
  final Parser _parser;

  Casl2(this._parser);

  factory Casl2.fromString(final String src) =>
      Casl2(ImplParser(ImplLexer.fromString(src)));

  (List<Node>, List<ParseError>) parseNode() {
    final errors = <ParseError>[];
    final nodes = <Node>[];
    Node? parent;

    while (true) {
      final result = _parser.nextNode(parent, _state);
      if (result.isError) {
        errors.add(result.error);
        continue;
      }

      final node = result.ok;
      if (node is EndNode) break;
      parent = node;
      nodes.add(node);
    }
    return (nodes, errors);
  }

  Result compile() {
    final (nodes, errors) = parseNode();

    final code = <Code>[];
    for (final node in nodes) {
      final result = node.code;
      if (result.isError) {
        errors.add(result.error);
        continue;
      }
      for (final c in result.ok) {
        code.add(c);
      }
    }

    return Result(code, errors);
  }
}

/// Parser return this Node
class Result {
  final List<Code> _code;
  final List<ParseError> _errors;

  Result(this._code, this._errors);

  bool get hasError => _errors.isNotEmpty;

  List<ParseError> get errors => _errors;

  List<int> code(int base) => _code.map((c) => c.value(base)).toList();
}
