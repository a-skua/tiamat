import '../ast/ast.dart';
import '../lexer/lexer.dart';
import '../token/token.dart';

class Parser {
  final Lexer _lexer;

  Parser(this._lexer);

  Program parseProgram() {
    final stmts = <Node>[];

    Node node = Root();
    while (true) {
      final stmt = _nextStmt(node);
      if (stmt == null) {
        return Program(stmts);
      }
      stmts.add(stmt);
      node = stmt;
    }
  }

  Statement? _nextStmt(Node parent) {
    var token = _lexer.nextToken();

    // FIXME skip empty
    while (token.type == TokenType.eol || token.type == TokenType.comment) {
      token = _lexer.nextToken();
    }

    if (token.type == TokenType.eof) {
      return null;
    }

    Token? label;
    Token? opecode;
    var operand = <Token>[];
    while (true) {
      switch (token.type) {
        case TokenType.label:
          label = token;
          break;
        case TokenType.opecode:
          opecode = token;
          break;
        case TokenType.comment:
          break;
        case TokenType.eof:
        case TokenType.eol:
          return Statement(
            parent,
            opecode as Token,
            operand,
            label: label,
          );
        default:
          operand.add(token);
      }
      token = _lexer.nextToken();
    }
  }
}
