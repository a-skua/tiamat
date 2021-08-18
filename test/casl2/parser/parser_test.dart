import 'package:tiamat/src/casl2/parser/parser.dart';
import 'package:tiamat/src/casl2/lexer/lexer.dart';
import 'package:test/test.dart';

void main() {
  test('parse', testPaarse);
}

void testPaarse() {
  final input = '''
MAIN    START                   ; コメント
        CALL    COUNT1          ; COUNT1呼び出し
        RET
        DC      'hello','world' ; 文字定数
        DC      'It''s a small world'
        DC      12,-34,56,-78   ; 10進定数
        DC      #1234,#CDEF     ; 16進定数
        END
'''
      .trim();

  final parser = Parser(Lexer(input));

  final expected = 'BLOCK('
      'STATEMENT(LABEL(MAIN),OPECODE(START))'
      ','
      'STATEMENT(OPECODE(CALL),OPERAND(IDENT(COUNT1)))'
      ','
      'STATEMENT(OPECODE(RET))'
      ','
      'STATEMENT(OPECODE(DC),OPERAND(STRING(\'hello\'),STRING(\'world\')))'
      ','
      'STATEMENT(OPECODE(DC),OPERAND(STRING(\'It\'\'s a small world\')))'
      ','
      'STATEMENT(OPECODE(DC),OPERAND(DEC(12),DEC(-34),DEC(56),DEC(-78)))'
      ','
      'STATEMENT(OPECODE(DC),OPERAND(HEX(#1234),HEX(#CDEF)))'
      ','
      'STATEMENT(OPECODE(END))'
      ')';

  expect(parser.parseProgram().toString(), equals(expected));
}
