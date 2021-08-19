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
GR1234  DC      GR1234,MAIN     ; アドレス定数
        END

COUNT1  START                   ;
;       入力    GR1:検索する語
;       処理    GR1中の'1'のビットの個数を求める
;       出力    GR0:GR1中の'1'のビットの個数
        PUSH    0,GR1           ;
        PUSH    0,GR2           ;
        SUBA    GR2,GR2         ; Count = 0
        AND     GR1,GR1         ; 全部のビットが'0'?
        JZE     RETURN          ; 全部のビットが'0'なら終了
MORE    LAD     GR2,1,GR2       ; Count = Count + 1
        LAD     GR0,-1,GR1      ; 最下位の'1'のビット1個を
        AND     GR1,GR0         ;   '0'に変える
        JNZ     MORE            ; '1'のビットが残っていれば繰り返し
RETURN  LD      GR0,GR2         ; GR0 = Count
        POP     GR2             ;
        POP     GR1             ;
        RET                     ; 呼び出しプログラムへ戻る
        END                     ;
'''
      .trim();

  final parser = Parser(Lexer(input));

  final expected = 'BLOCK('
      'STATEMENT(LABEL(MAIN),OPECODE(START))'
      ','
      'STATEMENT(OPECODE(CALL),OPERAND(IDENT(COUNT1)))' // TODO COUNT1 is label
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
      'STATEMENT(LABEL(GR1234),OPECODE(DC),OPERAND(IDENT(GR1234),IDENT(MAIN)))'
      ','
      'STATEMENT(OPECODE(END))'
      ','
      'STATEMENT(LABEL(COUNT1),OPECODE(START))'
      ','
      'STATEMENT(OPECODE(PUSH),OPERAND(DEC(0),GR(GR1)))' // TODO GR1 is register
      ','
      'STATEMENT(OPECODE(PUSH),OPERAND(DEC(0),GR(GR2)))'
      ','
      'STATEMENT(OPECODE(SUBA),OPERAND(GR(GR2),GR(GR2)))'
      ','
      'STATEMENT(OPECODE(AND),OPERAND(GR(GR1),GR(GR1)))'
      ','
      'STATEMENT(OPECODE(JZE),OPERAND(IDENT(RETURN)))'
      ','
      'STATEMENT(LABEL(MORE),OPECODE(LAD),OPERAND(GR(GR2),DEC(1),GR(GR2)))'
      ','
      'STATEMENT(OPECODE(LAD),OPERAND(GR(GR0),DEC(-1),GR(GR1)))'
      ','
      'STATEMENT(OPECODE(AND),OPERAND(GR(GR1),GR(GR0)))'
      ','
      'STATEMENT(OPECODE(JNZ),OPERAND(IDENT(MORE)))'
      ','
      'STATEMENT(LABEL(RETURN),OPECODE(LD),OPERAND(GR(GR0),GR(GR2)))'
      ','
      'STATEMENT(OPECODE(POP),OPERAND(GR(GR2)))'
      ','
      'STATEMENT(OPECODE(POP),OPERAND(GR(GR1)))'
      ','
      'STATEMENT(OPECODE(RET))'
      ','
      'STATEMENT(OPECODE(END))'
      ')';

  expect(parser.parseProgram().toString(), equals(expected));
}
