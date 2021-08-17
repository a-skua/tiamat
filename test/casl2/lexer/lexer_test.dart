import 'package:tiamat/src/casl2/token/token.dart';
import 'package:tiamat/src/casl2/lexer/lexer.dart';
import 'package:test/test.dart';

void main() {
  test('lexer', testNextToken);
}

List<int> toRunes(final String s) {
  return s.runes.toList();
}

/// Expected token struct
class ExpectedToken {
  final String value;
  final TokenType type;
  const ExpectedToken(this.value, this.type);
}

void testNextToken() {
  final input = '''
MAIN    START                   ; コメント
        CALL    COUNT1          ; COUNT1呼び出し
        RET
        DC      'hello','world' ; 文字定数
        DC      'Is''s a small world'
        DC      12,-34,56,-78   ; 10進定数
        DC      #1234,#CDEF     ; 16進定数
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

  final tests = <ExpectedToken>[
    ExpectedToken('MAIN', TokenType.label),
    ExpectedToken('START', TokenType.opecode),
    ExpectedToken('; コメント', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('CALL', TokenType.opecode),
    ExpectedToken('COUNT1', TokenType.ident),
    ExpectedToken('; COUNT1呼び出し', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('RET', TokenType.opecode),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('DC', TokenType.opecode),
    ExpectedToken("'hello'", TokenType.string),
    ExpectedToken("'world'", TokenType.string),
    ExpectedToken('; 文字定数', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('DC', TokenType.opecode),
    ExpectedToken("'Is''s a small world'", TokenType.string),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('DC', TokenType.opecode),
    ExpectedToken('12', TokenType.dec),
    ExpectedToken('-34', TokenType.dec),
    ExpectedToken('56', TokenType.dec),
    ExpectedToken('-78', TokenType.dec),
    ExpectedToken('; 10進定数', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('DC', TokenType.opecode),
    ExpectedToken('#1234', TokenType.hex),
    ExpectedToken('#CDEF', TokenType.hex),
    ExpectedToken('; 16進定数', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('END', TokenType.opecode),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('COUNT1', TokenType.label),
    ExpectedToken('START', TokenType.opecode),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken(';       入力    GR1:検索する語', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken(';       処理    GR1中の\'1\'のビットの個数を求める', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken(';       出力    GR0:GR1中の\'1\'のビットの個数', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('PUSH', TokenType.opecode),
    ExpectedToken('0', TokenType.dec),
    ExpectedToken('GR1', TokenType.ident),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('PUSH', TokenType.opecode),
    ExpectedToken('0', TokenType.dec),
    ExpectedToken('GR2', TokenType.ident),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('SUBA', TokenType.opecode),
    ExpectedToken('GR2', TokenType.ident),
    ExpectedToken('GR2', TokenType.ident),
    ExpectedToken('; Count = 0', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('AND', TokenType.opecode),
    ExpectedToken('GR1', TokenType.ident),
    ExpectedToken('GR1', TokenType.ident),
    ExpectedToken('; 全部のビットが\'0\'?', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('JZE', TokenType.opecode),
    ExpectedToken('RETURN', TokenType.ident),
    ExpectedToken('; 全部のビットが\'0\'なら終了', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('MORE', TokenType.label),
    ExpectedToken('LAD', TokenType.opecode),
    ExpectedToken('GR2', TokenType.ident),
    ExpectedToken('1', TokenType.dec),
    ExpectedToken('GR2', TokenType.ident),
    ExpectedToken('; Count = Count + 1', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('LAD', TokenType.opecode),
    ExpectedToken('GR0', TokenType.ident),
    ExpectedToken('-1', TokenType.dec),
    ExpectedToken('GR1', TokenType.ident),
    ExpectedToken('; 最下位の\'1\'のビット1個を', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('AND', TokenType.opecode),
    ExpectedToken('GR1', TokenType.ident),
    ExpectedToken('GR0', TokenType.ident),
    ExpectedToken(';   \'0\'に変える', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('JNZ', TokenType.opecode),
    ExpectedToken('MORE', TokenType.ident),
    ExpectedToken('; \'1\'のビットが残っていれば繰り返し', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('RETURN', TokenType.label),
    ExpectedToken('LD', TokenType.opecode),
    ExpectedToken('GR0', TokenType.ident),
    ExpectedToken('GR2', TokenType.ident),
    ExpectedToken('; GR0 = Count', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('POP', TokenType.opecode),
    ExpectedToken('GR2', TokenType.ident),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('POP', TokenType.opecode),
    ExpectedToken('GR1', TokenType.ident),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('RET', TokenType.opecode),
    ExpectedToken('; 呼び出しプログラムへ戻る', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('END', TokenType.opecode),
    ExpectedToken(';', TokenType.comment),
  ];

  final runes = input.runes.toList();
  var currentLine = 0;
  final l = Lexer(input);
  for (final tt in tests) {
    final token = l.nextToken();

    expect(token.type, equals(tt.type));
    expect(token.runesAsString, equals(tt.value));
    expect(
      String.fromCharCodes(runes.getRange(token.start, token.end)),
      token.runesAsString,
    );
    expect(token.line, equals(currentLine));

    if (token.type == TokenType.eol) {
      currentLine += 1;
    }
  }

  final eofToken = l.nextToken();
  expect(eofToken.type, equals(TokenType.eof));
  expect(eofToken.runesAsString, equals(''));
}
