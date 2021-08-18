import 'package:tiamat/src/casl2/parser/parser.dart';
import 'package:tiamat/src/casl2/lexer/lexer.dart';
import 'package:test/test.dart';

void main() {
  test('example', () {
    final parser = Parser(Lexer('todo'));
  });
}
