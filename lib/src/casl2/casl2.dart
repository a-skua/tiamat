import './lexer/lexer.dart';
import './parser/parser.dart';
import './ast/ast.dart';

/// CASL2 instance.
class Casl2 {
  final Program _program;

  factory Casl2.compile(String src) {
    final parser = Parser(Lexer(src.runes.toList()));
    return Casl2._internal(parser.parseProgram());
  }

  Casl2._internal(this._program);

  List<int> getCode([final int startPoint = 0]) {
    _program.env.startPoint = startPoint;
    return _program.code;
  }
}
