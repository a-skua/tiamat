import '../ast/ast.dart';
import '../lexer/lexer.dart';
import '../token/token.dart';

class Parser {
  final Lexer _lexer;

  Parser(this._lexer);

  Root parseProgram() {
    final stmts = <Node>[];

    Token? label;
    Token? opecode;
    List<Token> operand = [];
    while (true) {
      final token = _lexer.nextToken();
      if (token.type == TokenType.eof) {
        stmts.add(Statement(
          opecode as Token,
          operand,
          label: label,
        ));
        break;
      }

      switch (token.type) {
        case TokenType.label:
          label = token;
          break;
        case TokenType.opecode:
          opecode = token;
          break;
        case TokenType.comment:
          break;
        case TokenType.eol:
          stmts.add(Statement(
            opecode as Token,
            operand,
            label: label,
          ));
          label = null;
          opecode = null;
          operand = [];
          break;
        default:
          operand.add(token);
      }
    }

    return Root(stmts);
  }
}
