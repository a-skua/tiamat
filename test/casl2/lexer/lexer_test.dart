import 'package:tiamat/src/casl2/token/token.dart';
import 'package:tiamat/src/casl2/lexer/lexer.dart';
import 'package:test/test.dart';

void main() {
  test('lexer', testNext);
}

List<int> toRunes(final String s) {
  return s.runes.toList();
}

void testNext() {
  final input = '''
MAIN    START           ; コメント
        CALL    COUNT1  ; COUNT1呼び出し
        RET
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

  final tests = <Token>[
    Token('MAIN'.runes, TokenType.label),
    Token('START'.runes, TokenType.opecode),
    Token('; コメント'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token('CALL'.runes, TokenType.opecode),
    Token('COUNT1'.runes, TokenType.operand),
    Token('; COUNT1呼び出し'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token('RET'.runes, TokenType.opecode),
    Token([], TokenType.eol),
    Token('END'.runes, TokenType.opecode),
    Token([], TokenType.eol),
    Token([], TokenType.eol),
    Token('COUNT1'.runes, TokenType.label),
    Token('START'.runes, TokenType.opecode),
    Token(';'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token(';       入力    GR1:検索する語'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token(';       処理    GR1中の\'1\'のビットの個数を求める'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token(';       出力    GR0:GR1中の\'1\'のビットの個数'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token('PUSH'.runes, TokenType.opecode),
    Token('0,GR1'.runes, TokenType.operand),
    Token(';'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token('PUSH'.runes, TokenType.opecode),
    Token('0,GR2'.runes, TokenType.operand),
    Token(';'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token('SUBA'.runes, TokenType.opecode),
    Token('GR2,GR2'.runes, TokenType.operand),
    Token('; Count = 0'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token('AND'.runes, TokenType.opecode),
    Token('GR1,GR1'.runes, TokenType.operand),
    Token('; 全部のビットが\'0\'?'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token('JZE'.runes, TokenType.opecode),
    Token('RETURN'.runes, TokenType.operand),
    Token('; 全部のビットが\'0\'なら終了'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token('MORE'.runes, TokenType.label),
    Token('LAD'.runes, TokenType.opecode),
    Token('GR2,1,GR2'.runes, TokenType.operand),
    Token('; Count = Count + 1'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token('LAD'.runes, TokenType.opecode),
    Token('GR0,-1,GR1'.runes, TokenType.operand),
    Token('; 最下位の\'1\'のビット1個を'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token('AND'.runes, TokenType.opecode),
    Token('GR1,GR0'.runes, TokenType.operand),
    Token(';   \'0\'に変える'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token('JNZ'.runes, TokenType.opecode),
    Token('MORE'.runes, TokenType.operand),
    Token('; \'1\'のビットが残っていれば繰り返し'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token('RETURN'.runes, TokenType.label),
    Token('LD'.runes, TokenType.opecode),
    Token('GR0,GR2'.runes, TokenType.operand),
    Token('; GR0 = Count'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token('POP'.runes, TokenType.opecode),
    Token('GR2'.runes, TokenType.operand),
    Token(';'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token('POP'.runes, TokenType.opecode),
    Token('GR1'.runes, TokenType.operand),
    Token(';'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token('RET'.runes, TokenType.opecode),
    Token('; 呼び出しプログラムへ戻る'.runes, TokenType.comment),
    Token([], TokenType.eol),
    Token('END'.runes, TokenType.opecode),
    Token(';'.runes, TokenType.comment),
    Token([], TokenType.eof),
  ];

  final l = Lexer(input);
  for (final tt in tests) {
    final token = l.nextToken();
    expect(token.type, equals(tt.type));
    expect(token.runesAsString, equals(tt.runesAsString));
  }

  final eofToken = l.nextToken();
  expect(eofToken.type, equals(TokenType.eof));
  expect(eofToken.runesAsString, equals(''));
}
