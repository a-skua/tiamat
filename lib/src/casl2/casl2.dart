import './lexer/lexer.dart';
import './parser/ast.dart';
import './parser/parser.dart';
import '../typedef/typedef.dart';
import './compiler/state.dart';

export './parser/ast.dart';

/// CASL2 instance.
class Casl2 {
  final _state = State();
  final Parser _parser;

  Casl2(this._parser);

  factory Casl2.fromString(final String src) =>
      Casl2(Parser(Lexer.fromString(src)));

  Result<Module, List<ParseError>> parse() {
    final errs = <ParseError>[];
    final stmts = <Statement>[];

    for (final result in _parser.nextStatement(_state)) {
      if (result.isErr) {
        errs.add(result.err);
        continue;
      }

      final node = result.ok;
      stmts.add(node);
    }

    if (errs.isNotEmpty) {
      return Err(errs);
    }

    return Ok(Module(stmts));
  }

  Result<List<Code>, List<ParseError>> compile() {
    final result = parse();

    if (result.isErr) {
      return Err(result.err);
    }

    return Err([ParseError.todo('Not implemented')]);
  }
}
