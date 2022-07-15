import './lexer/lexer.dart';
import './parser/parser.dart';
import './ast/ast.dart';

/// CASL2 instance.
class Casl2 {
  final ParserInterface _parser;

  Casl2(this._parser);

  factory Casl2.fromString(final String src) =>
      Casl2(Parser(Lexer.fromString(src)));

  Result compile() {
    final starts = <Statement>[];
    Statement? start;
    final stmts = <Statement>[];
    final env = Env();
    final errors = <ErrorNode>[];

    Node parent = Root();
    while (true) {
      final node = _parser.nextStmt(parent, env);
      if (node is End) {
        if (start == null) {
          if (starts.isNotEmpty) {
            start = starts.first;
          } else if (stmts.isNotEmpty) {
            start = stmts.first;
          }
        }

        return Result(
          stmts,
          env: env,
          errors: errors,
          start: start,
        );
      }

      if (node is ErrorNode) {
        errors.add(node);
        continue;
      }

      final stmt = node as Statement;
      if (stmt.label.isNotEmpty) {
        env.labels[stmt.label] = stmt;
      }
      if (stmt.opecode == 'START') {
        starts.add(stmt);
        if (stmt.label == env.entryLabel) {
          start = stmt;
        }
      }

      stmts.add(stmt);
      parent = stmt;
    }
  }
}

/// Parser return this Node
class Result {
  final Env env;
  final List<ErrorNode> errors;
  final List<Statement> statements;
  // TODO Statement? to Statement
  final Statement? start;

  Result(
    this.statements, {
    required this.env,
    required this.errors,
    this.start,
  });

  // Error
  bool get hasError => errors.isNotEmpty;

  // code size
  int get size =>
      statements.map((stmt) => stmt.size).reduce((sum, size) => sum + size);

  List<int> get code => statements.map((stmt) => stmt.code).reduce((all, code) {
        all.addAll(code);
        return all;
      });

  @override
  String toString() => statements.join(',');
}
