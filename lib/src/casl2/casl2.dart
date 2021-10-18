import './lexer/lexer.dart';
import './parser/parser.dart';
import './ast/ast.dart';

/// CASL2 instance.
class Casl2 {
  final Program _program;

  Casl2(this._program);

  factory Casl2.compile(final String src) {
    final parser = Parser(Lexer(src.runes));
    return Casl2(parser.parseProgram());
  }

  Program get program => _program;
}
