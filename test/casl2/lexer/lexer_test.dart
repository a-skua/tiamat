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

  final tests = <ExpectedToken>[
    ExpectedToken('MAIN', TokenType.label),
    ExpectedToken('START', TokenType.opecode),
    ExpectedToken('; コメント', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('CALL', TokenType.opecode),
    ExpectedToken('COUNT1', TokenType.operand),
    ExpectedToken('; COUNT1呼び出し', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('RET', TokenType.opecode),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('END', TokenType.opecode),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('COUNT1', TokenType.label),
    ExpectedToken('START', TokenType.opecode),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken(';       入力    GR1:検索する語', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken(';       処理    GR1中の\'1\'のビットの個数を求める', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken(';       出力    GR0:GR1中の\'1\'のビットの個数', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('PUSH', TokenType.opecode),
    ExpectedToken('0,GR1', TokenType.operand),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('PUSH', TokenType.opecode),
    ExpectedToken('0,GR2', TokenType.operand),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('SUBA', TokenType.opecode),
    ExpectedToken('GR2,GR2', TokenType.operand),
    ExpectedToken('; Count = 0', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('AND', TokenType.opecode),
    ExpectedToken('GR1,GR1', TokenType.operand),
    ExpectedToken('; 全部のビットが\'0\'?', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('JZE', TokenType.opecode),
    ExpectedToken('RETURN', TokenType.operand),
    ExpectedToken('; 全部のビットが\'0\'なら終了', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('MORE', TokenType.label),
    ExpectedToken('LAD', TokenType.opecode),
    ExpectedToken('GR2,1,GR2', TokenType.operand),
    ExpectedToken('; Count = Count + 1', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('LAD', TokenType.opecode),
    ExpectedToken('GR0,-1,GR1', TokenType.operand),
    ExpectedToken('; 最下位の\'1\'のビット1個を', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('AND', TokenType.opecode),
    ExpectedToken('GR1,GR0', TokenType.operand),
    ExpectedToken(';   \'0\'に変える', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('JNZ', TokenType.opecode),
    ExpectedToken('MORE', TokenType.operand),
    ExpectedToken('; \'1\'のビットが残っていれば繰り返し', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('RETURN', TokenType.label),
    ExpectedToken('LD', TokenType.opecode),
    ExpectedToken('GR0,GR2', TokenType.operand),
    ExpectedToken('; GR0 = Count', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('POP', TokenType.opecode),
    ExpectedToken('GR2', TokenType.operand),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('POP', TokenType.opecode),
    ExpectedToken('GR1', TokenType.operand),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('RET', TokenType.opecode),
    ExpectedToken('; 呼び出しプログラムへ戻る', TokenType.comment),
    ExpectedToken('', TokenType.eol),
    ExpectedToken('END', TokenType.opecode),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('', TokenType.eof),
  ];

  final l = Lexer(input);
  for (final tt in tests) {
    final token = l.nextToken();
    expect(token.type, equals(tt.type));
    expect(token.runesAsString, equals(tt.value));
  }

  final eofToken = l.nextToken();
  expect(eofToken.type, equals(TokenType.eof));
  expect(eofToken.runesAsString, equals(''));
}
