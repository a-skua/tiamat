import './lexer/lexer.dart';
import './parser/ast.dart';
import './parser/parser.dart';
import '../typedef/typedef.dart';
import './compiler/compiler.dart';

// TODO
export './compiler/compiler.dart' show Code;

abstract class Casl2Error {
  final String message;
  final int start;
  final int end;
  final int lineStart;
  final int lineNumber;

  const Casl2Error(
    this.message, {
    required this.start,
    required this.end,
    required this.lineStart,
    required this.lineNumber,
  });

  @override
  String toString() => 'L$lineNumber: $message';
}

/// CASL2 instance.
final class Casl2 {
  final Parser _parser;
  final Compiler _compiler;

  const Casl2(this._parser, this._compiler);

  factory Casl2.fromString(final String src) =>
      Casl2(Parser(Lexer.fromString(src)), Compiler());

  Result<List<Statement>, List<ParseError>> parse() {
    final errs = <ParseError>[];
    final stmts = <Statement>[];

    for (final result in _parser.nextStatement()) {
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

    return Ok(stmts);
  }

  Result<Module, List<Casl2Error>> compile() {
    final result = parse();

    if (result.isErr) {
      return Err(result.err);
    }

    final errs = <CompileError>[];
    for (final stmt in result.ok) {
      final result = _compiler.compile(stmt);
      if (result.isErr) {
        errs.add(result.err);
      }
    }

    // TODO
    return Err(errs);
  }
}

/// CASL2 Module
final class Module {
  Module();
}
