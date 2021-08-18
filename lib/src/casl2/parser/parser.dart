import '../ast/ast.dart';
import '../lexer/lexer.dart';

class Parser {
  final Lexer _lexer;

  Parser(this._lexer);

  Root parser() => Root();
}
