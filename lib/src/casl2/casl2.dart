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

  (ModuleNode, List<ParseError>) parseNode() {
    final errors = <ParseError>[];
    final nodes = <StatementNode>[];

    for (final result in _parser.nextNode(_state)) {
      if (result.isError) {
        errors.add(result.error);
        continue;
      }

      final node = result.ok;
      nodes.add(node);
    }
    return (ModuleNode(nodes), errors);
  }

  Result compile() {
    final (mod, errors) = parseNode();
    final code = <Code>[];

    final result = mod.code;
    if (result.isError) {
      errors.add(result.error);
    } else {
      code.addAll(result.ok);
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