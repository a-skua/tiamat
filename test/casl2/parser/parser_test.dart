import 'package:tiamat/src/casl2/lexer/lexer.dart';
import 'package:tiamat/src/casl2/parser/parser.dart';
import 'package:test/test.dart';

void main() {
  group('Parser', () {
    test('nextStatement() 1', testParserNextStatement1);
    test('nextStatement() 2', testParserNextStatement2);
  });
}

void testParserNextStatement1() {
  final input = '''
MAIN    START                   ; コメント
        CALL    COUNT1          ; COUNT1呼び出し
        IN      GR1234,2        ; マクロ
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
        ; LD      GR0,GR1         ; 不要ファイルのコメントアウト例
        RPUSH
        RPOP
        POP     GR2             ;
        POP     GR1             ;
        RET                     ; 呼び出しプログラムへ戻る
        END                     ;

; ERROR: 文字列が正常に終了していないパターン
        DC 'hello,world
''';

  final expected = [
    'Ok(SUBROUTINE('
        'LABEL(MAIN),'
        'PROCESS('
        'STATEMENT(OPECODE(CALL),OPERAND(REF(COUNT1))),'
        'STATEMENT(OPECODE(IN),OPERAND(REF(GR1234),DEC(2))),'
        'STATEMENT(OPECODE(RET)),'
        'STATEMENT(OPECODE(DC),OPERAND(TEXT(\'hello\'),TEXT(\'world\'))),'
        'STATEMENT(OPECODE(DC),OPERAND(TEXT(\'It\'\'s a small world\'))),'
        'STATEMENT(OPECODE(DC),OPERAND(DEC(12),DEC(-34),DEC(56),DEC(-78))),'
        'STATEMENT(OPECODE(DC),OPERAND(HEX(#1234),HEX(#CDEF))),'
        'STATEMENT(LABEL(GR1234),OPECODE(DC),OPERAND(REF(GR1234),REF(MAIN)))'
        ')))',
    'Ok(SUBROUTINE('
        'LABEL(COUNT1),'
        'PROCESS('
        'STATEMENT(OPECODE(PUSH),OPERAND(DEC(0),GR(GR1))),'
        'STATEMENT(OPECODE(PUSH),OPERAND(DEC(0),GR(GR2))),'
        'STATEMENT(OPECODE(SUBA),OPERAND(GR(GR2),GR(GR2))),'
        'STATEMENT(OPECODE(AND),OPERAND(GR(GR1),GR(GR1))),'
        'STATEMENT(OPECODE(JZE),OPERAND(REF(RETURN))),'
        'STATEMENT(LABEL(MORE),OPECODE(LAD),OPERAND(GR(GR2),DEC(1),GR(GR2))),'
        'STATEMENT(OPECODE(LAD),OPERAND(GR(GR0),DEC(-1),GR(GR1))),'
        'STATEMENT(OPECODE(AND),OPERAND(GR(GR1),GR(GR0))),'
        'STATEMENT(OPECODE(JNZ),OPERAND(REF(MORE))),'
        'STATEMENT(LABEL(RETURN),OPECODE(LD),OPERAND(GR(GR0),GR(GR2))),'
        'STATEMENT(OPECODE(RPUSH)),'
        'STATEMENT(OPECODE(RPOP)),'
        'STATEMENT(OPECODE(POP),OPERAND(GR(GR2))),'
        'STATEMENT(OPECODE(POP),OPERAND(GR(GR1))),'
        'STATEMENT(OPECODE(RET))'
        ')))',
    'Err(L35: [SYNTAX ERROR] Invalid String: \'hello,world)',
    'Ok(())',
  ];

  final parser = Parser(Lexer.fromString(input));

  var i = 0;
  for (final actual in parser.nextStatement()) {
    expect('$actual', equals(expected[i++]));
  }
}

void testParserNextStatement2() {
  final input = '''
MAIN    START   FOO             ; コメント
        CALL    COUNT1          ; COUNT1呼び出し
        RET
        DC      'hello','world' ; 文字定数
        DC      'it''s a small world'
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
        RPUSH
        RPOP
        POP     GR2             ;
        POP     GR1             ;
        RET                     ; 呼び出しプログラムへ戻る
        END                     ;
''';

  final expected = [
    'Ok(SUBROUTINE('
        'LABEL(MAIN),'
        'START(REF(FOO)),'
        'PROCESS('
        'STATEMENT(OPECODE(CALL),OPERAND(REF(COUNT1))),'
        'STATEMENT(OPECODE(RET)),'
        'STATEMENT(OPECODE(DC),OPERAND(TEXT(\'hello\'),TEXT(\'world\'))),'
        'STATEMENT(OPECODE(DC),OPERAND(TEXT(\'it\'\'s a small world\'))),'
        'STATEMENT(OPECODE(DC),OPERAND(DEC(12),DEC(-34),DEC(56),DEC(-78))),'
        'STATEMENT(OPECODE(DC),OPERAND(HEX(#1234),HEX(#CDEF))),'
        'STATEMENT(LABEL(GR1234),OPECODE(DC),OPERAND(REF(GR1234),REF(MAIN)))'
        ')))',
    'Ok(SUBROUTINE('
        'LABEL(COUNT1),'
        'PROCESS('
        'STATEMENT(OPECODE(PUSH),OPERAND(DEC(0),GR(GR1))),'
        'STATEMENT(OPECODE(PUSH),OPERAND(DEC(0),GR(GR2))),'
        'STATEMENT(OPECODE(SUBA),OPERAND(GR(GR2),GR(GR2))),'
        'STATEMENT(OPECODE(AND),OPERAND(GR(GR1),GR(GR1))),'
        'STATEMENT(OPECODE(JZE),OPERAND(REF(RETURN))),'
        'STATEMENT(LABEL(MORE),OPECODE(LAD),OPERAND(GR(GR2),DEC(1),GR(GR2))),'
        'STATEMENT(OPECODE(LAD),OPERAND(GR(GR0),DEC(-1),GR(GR1))),'
        'STATEMENT(OPECODE(AND),OPERAND(GR(GR1),GR(GR0))),'
        'STATEMENT(OPECODE(JNZ),OPERAND(REF(MORE))),'
        'STATEMENT(LABEL(RETURN),OPECODE(LD),OPERAND(GR(GR0),GR(GR2))),'
        'STATEMENT(OPECODE(RPUSH)),'
        'STATEMENT(OPECODE(RPOP)),'
        'STATEMENT(OPECODE(POP),OPERAND(GR(GR2))),'
        'STATEMENT(OPECODE(POP),OPERAND(GR(GR1))),'
        'STATEMENT(OPECODE(RET))'
        ')))',
    'Ok(())',
  ];

  final parser = Parser(Lexer.fromString(input));

  var i = 0;
  for (final actual in parser.nextStatement()) {
    expect('$actual', equals(expected[i++]));
  }
}
