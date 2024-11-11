import 'package:tiamat/src/casl2/token/token.dart';
import 'package:tiamat/src/casl2/lexer/lexer.dart';
import 'package:test/test.dart';

void main() {
  test('next token', testNextToken);
  test('label error', testLabelError);
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
\t      DC\t    'hello','world' ; 文字定数
  \t    DC      'It''s a small world'
    \t  DC      12,-34,56,-78   ; 10進定数
      \tDC      #1234,#CDEF     ; 16進定数
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
        POP     GR2             ;
        POP     GR1             ;
        RET                     ; 呼び出しプログラムへ戻る
        END                     ;
''';

  final tests = <ExpectedToken>[
    ExpectedToken('MAIN', TokenType.label),
    ExpectedToken('    ', TokenType.space),
    ExpectedToken('START', TokenType.op),
    ExpectedToken('                   ', TokenType.space),
    ExpectedToken('; コメント', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('CALL', TokenType.op),
    ExpectedToken('    ', TokenType.space),
    ExpectedToken('COUNT1', TokenType.ref),
    ExpectedToken('          ', TokenType.space),
    ExpectedToken('; COUNT1呼び出し', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('RET', TokenType.op),
    ExpectedToken('     ', TokenType.space),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('\t      ', TokenType.space),
    ExpectedToken('DC', TokenType.op),
    ExpectedToken('\t    ', TokenType.space),
    ExpectedToken("'hello'", TokenType.text),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken("'world'", TokenType.text),
    ExpectedToken(' ', TokenType.space),
    ExpectedToken('; 文字定数', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('  \t    ', TokenType.space),
    ExpectedToken('DC', TokenType.op),
    ExpectedToken('      ', TokenType.space),
    ExpectedToken("'It''s a small world'", TokenType.text),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('    \t  ', TokenType.space),
    ExpectedToken('DC', TokenType.op),
    ExpectedToken('      ', TokenType.space),
    ExpectedToken('12', TokenType.dec),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('-34', TokenType.dec),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('56', TokenType.dec),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('-78', TokenType.dec),
    ExpectedToken('   ', TokenType.space),
    ExpectedToken('; 10進定数', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('      \t', TokenType.space),
    ExpectedToken('DC', TokenType.op),
    ExpectedToken('      ', TokenType.space),
    ExpectedToken('#1234', TokenType.hex),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('#CDEF', TokenType.hex),
    ExpectedToken('     ', TokenType.space),
    ExpectedToken('; 16進定数', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('GR1234', TokenType.label),
    ExpectedToken('  ', TokenType.space),
    ExpectedToken('DC', TokenType.op),
    ExpectedToken('      ', TokenType.space),
    ExpectedToken('GR1234', TokenType.ref),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('MAIN', TokenType.ref),
    ExpectedToken('     ', TokenType.space),
    ExpectedToken('; アドレス定数', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('END', TokenType.op),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('COUNT1', TokenType.label),
    ExpectedToken('  ', TokenType.space),
    ExpectedToken('START', TokenType.op),
    ExpectedToken('                   ', TokenType.space),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken(';       入力    GR1:検索する語', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken(';       処理    GR1中の\'1\'のビットの個数を求める', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken(';       出力    GR0:GR1中の\'1\'のビットの個数', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('PUSH', TokenType.op),
    ExpectedToken('    ', TokenType.space),
    ExpectedToken('0', TokenType.dec),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('GR1', TokenType.gr),
    ExpectedToken('           ', TokenType.space),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('PUSH', TokenType.op),
    ExpectedToken('    ', TokenType.space),
    ExpectedToken('0', TokenType.dec),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('GR2', TokenType.gr),
    ExpectedToken('           ', TokenType.space),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('SUBA', TokenType.op),
    ExpectedToken('    ', TokenType.space),
    ExpectedToken('GR2', TokenType.gr),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('GR2', TokenType.gr),
    ExpectedToken('         ', TokenType.space),
    ExpectedToken('; Count = 0', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('AND', TokenType.op),
    ExpectedToken('     ', TokenType.space),
    ExpectedToken('GR1', TokenType.gr),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('GR1', TokenType.gr),
    ExpectedToken('         ', TokenType.space),
    ExpectedToken('; 全部のビットが\'0\'?', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('JZE', TokenType.op),
    ExpectedToken('     ', TokenType.space),
    ExpectedToken('RETURN', TokenType.ref),
    ExpectedToken('          ', TokenType.space),
    ExpectedToken('; 全部のビットが\'0\'なら終了', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('MORE', TokenType.label),
    ExpectedToken('    ', TokenType.space),
    ExpectedToken('LAD', TokenType.op),
    ExpectedToken('     ', TokenType.space),
    ExpectedToken('GR2', TokenType.gr),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('1', TokenType.dec),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('GR2', TokenType.gr),
    ExpectedToken('       ', TokenType.space),
    ExpectedToken('; Count = Count + 1', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('LAD', TokenType.op),
    ExpectedToken('     ', TokenType.space),
    ExpectedToken('GR0', TokenType.gr),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('-1', TokenType.dec),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('GR1', TokenType.gr),
    ExpectedToken('      ', TokenType.space),
    ExpectedToken('; 最下位の\'1\'のビット1個を', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('AND', TokenType.op),
    ExpectedToken('     ', TokenType.space),
    ExpectedToken('GR1', TokenType.gr),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('GR0', TokenType.gr),
    ExpectedToken('         ', TokenType.space),
    ExpectedToken(';   \'0\'に変える', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('JNZ', TokenType.op),
    ExpectedToken('     ', TokenType.space),
    ExpectedToken('MORE', TokenType.ref),
    ExpectedToken('            ', TokenType.space),
    ExpectedToken('; \'1\'のビットが残っていれば繰り返し', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('RETURN', TokenType.label),
    ExpectedToken('  ', TokenType.space),
    ExpectedToken('LD', TokenType.op),
    ExpectedToken('      ', TokenType.space),
    ExpectedToken('GR0', TokenType.gr),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('GR2', TokenType.gr),
    ExpectedToken('         ', TokenType.space),
    ExpectedToken('; GR0 = Count', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken(
      '; LD      GR0,GR1         ; 不要ファイルのコメントアウト例',
      TokenType.comment,
    ),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('POP', TokenType.op),
    ExpectedToken('     ', TokenType.space),
    ExpectedToken('GR2', TokenType.gr),
    ExpectedToken('             ', TokenType.space),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('POP', TokenType.op),
    ExpectedToken('     ', TokenType.space),
    ExpectedToken('GR1', TokenType.gr),
    ExpectedToken('             ', TokenType.space),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('RET', TokenType.op),
    ExpectedToken('                     ', TokenType.space),
    ExpectedToken('; 呼び出しプログラムへ戻る', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('END', TokenType.op),
    ExpectedToken('                     ', TokenType.space),
    ExpectedToken(';', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
  ];

  final runes = input.runes.toList();
  var currentLineStart = 0;
  var currentLineNumber = 1;
  final l = Lexer(runes);
  for (final tt in tests) {
    final token = l.nextToken();

    expect(token.isError, equals(false), reason: 'unexpected error $token');

    testToken(token.ok, runes, currentLineStart, currentLineNumber, tt);

    if (token.ok.type == TokenType.eol) {
      currentLineStart = token.ok.end;
      currentLineNumber += 1;
    }
  }

  final eofToken = l.nextToken();
  expect(eofToken.isError, equals(false), reason: 'unexpected error $eofToken');

  expect(eofToken.ok.type, equals(TokenType.eof));
  expect(eofToken.ok.runes, equals(''));
  expect(eofToken.toString(), equals('EOF()'));
}

void testLabelError() {
  final input = '''
MAIN    START                   ; コメント
        JUMP    GR1
        SUBA    GR1,GR1
GR1     SUBA    GR2,GR2         ; ラベルエラー
        RET
        END
''';

  final tests = [
    ExpectedToken('MAIN', TokenType.label),
    ExpectedToken('    ', TokenType.space),
    ExpectedToken('START', TokenType.op),
    ExpectedToken('                   ', TokenType.space),
    ExpectedToken('; コメント', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('JUMP', TokenType.op),
    ExpectedToken('    ', TokenType.space),
    ExpectedToken('GR1', TokenType.gr),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('SUBA', TokenType.op),
    ExpectedToken('    ', TokenType.space),
    ExpectedToken('GR1', TokenType.gr),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('GR1', TokenType.gr),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('GR1', TokenType.unexpected),
    ExpectedToken('     ', TokenType.space),
    ExpectedToken('SUBA', TokenType.op),
    ExpectedToken('    ', TokenType.space),
    ExpectedToken('GR2', TokenType.gr),
    ExpectedToken(',', TokenType.separation),
    ExpectedToken('GR2', TokenType.gr),
    ExpectedToken('         ', TokenType.space),
    ExpectedToken('; ラベルエラー', TokenType.comment),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('RET', TokenType.op),
    ExpectedToken('\n', TokenType.eol),
    ExpectedToken('        ', TokenType.space),
    ExpectedToken('END', TokenType.op),
    ExpectedToken('\n', TokenType.eol),
  ];

  final expectedError = [
    'GR1 cannot be used as label',
  ].iterator;

  final runes = input.runes.toList();
  var currentLineStart = 0;
  var currentLineNumber = 1;
  final l = Lexer(runes);
  for (final tt in tests) {
    final token = l.nextToken();
    if (token.isError) {
      final err = token.error;
      expect(expectedError.moveNext(), isTrue);
      expect(err.token.type, equals(TokenType.unexpected));
      expect(err.message, equals(expectedError.current));
      continue;
    }

    testToken(token.ok, runes, currentLineStart, currentLineNumber, tt);

    if (token.ok.type == TokenType.eol) {
      currentLineStart = token.ok.end;
      currentLineNumber += 1;
    }
  }

  final eofToken = l.nextToken();
  expect(eofToken.isError, equals(false), reason: 'unexpected error $eofToken');

  expect(eofToken.ok.type, equals(TokenType.eof));
  expect(eofToken.ok.runes, equals(''));
  expect(eofToken.ok.toString(), equals('EOF()'));
}

/// tester
void testToken(Token token, List<int> runes, int lineStart, int lineNumber,
    ExpectedToken expected) {
  expect(token.type, equals(expected.type));
  expect(token.runes, equals(expected.value));
  expect(
    String.fromCharCodes(runes.getRange(token.start, token.end)),
    token.runes,
  );
  expect(token.lineStart, equals(lineStart));
  expect(token.lineNumber, equals(lineNumber));
}