import '../ast/ast.dart';
import '../lexer/lexer.dart';
import '../token/token.dart';

class Parser {
  final Lexer _lexer;

  Parser(this._lexer);

  Root parseProgram() {
    final stmts = <Node>[];

    while (true) {
      final stmt = _nextStmt();
      if (stmt == null) {
        return Root(stmts);
      }
      stmts.add(stmt);
    }
  }

  Statement? _nextStmt() {
    var token = _lexer.nextToken();
    if (token.type == TokenType.eof) {
      return null;
    }

    // FIXME skip empty
    while (token.type == TokenType.eol || token.type == TokenType.comment) {
      token = _lexer.nextToken();
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
