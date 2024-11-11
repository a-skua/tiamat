import './lexer/lexer.dart';
import './ast/ast.dart' hide Parser;
import './parser/parser.dart';
import './typedef.dart';

export './ast/ast.dart' hide Parser;

/// CASL2 instance.
class Casl2 {
  final _state = State();
  final Parser _parser;

  Casl2(this._parser);

  factory Casl2.fromString(final String src) =>
      Casl2(Parser(Lexer.fromString(src)));

  Result<ModuleNode, List<ParseError>> parse() {
    final errs = <ParseError>[];
    final stmts = <StatementNode>[];

    for (final result in _parser.nextStatement(_state)) {
      if (result.isError) {
        errs.add(result.error);
        continue;
      }

      final node = result.ok;
      stmts.add(node);
    }

    if (errs.isNotEmpty) {
      return Result.err(errs);
    }

    return Result.ok(ModuleNode(stmts));
  }

  Result<List<Code>, List<ParseError>> compile() {
    final result = parse();

    if (result.isError) {
      return Result.err(result.error);
    }

    final code = result.ok.code;
    if (code.isError) {
      return Result.err([code.error]);
    }

    return Result.ok(code.ok);
  }
}