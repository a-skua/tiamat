import 'package:tiamat/casl2.dart';
import 'package:test/test.dart';

void main() {
  group('Lexer', () {
    test('nextToken()', testNextToken);
    test('label error', testLabelError);
  });
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

  final tests = [
    Token.label('MAIN'.runes),
    Token.space('    '.runes),
    Token.op('START'.runes),
    Token.space('                   '.runes),
    Token.comment('; コメント'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('CALL'.runes),
    Token.space('    '.runes),
    Token.ref('COUNT1'.runes),
    Token.space('          '.runes),
    Token.comment('; COUNT1呼び出し'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('RET'.runes),
    Token.space('     '.runes),
    Token.eol('\n'.runes),
    Token.space('\t      '.runes),
    Token.op('DC'.runes),
    Token.space('\t    '.runes),
    Token.text("'hello'".runes),
    Token.separation(','.runes),
    Token.text("'world'".runes),
    Token.space(' '.runes),
    Token.comment('; 文字定数'.runes),
    Token.eol('\n'.runes),
    Token.space('  \t    '.runes),
    Token.op('DC'.runes),
    Token.space('      '.runes),
    Token.text("'It''s a small world'".runes),
    Token.eol('\n'.runes),
    Token.space('    \t  '.runes),
    Token.op('DC'.runes),
    Token.space('      '.runes),
    Token.dec('12'.runes),
    Token.separation(','.runes),
    Token.dec('-34'.runes),
    Token.separation(','.runes),
    Token.dec('56'.runes),
    Token.separation(','.runes),
    Token.dec('-78'.runes),
    Token.space('   '.runes),
    Token.comment('; 10進定数'.runes),
    Token.eol('\n'.runes),
    Token.space('      \t'.runes),
    Token.op('DC'.runes),
    Token.space('      '.runes),
    Token.hex('#1234'.runes),
    Token.separation(','.runes),
    Token.hex('#CDEF'.runes),
    Token.space('     '.runes),
    Token.comment('; 16進定数'.runes),
    Token.eol('\n'.runes),
    Token.label('GR1234'.runes),
    Token.space('  '.runes),
    Token.op('DC'.runes),
    Token.space('      '.runes),
    Token.ref('GR1234'.runes),
    Token.separation(','.runes),
    Token.ref('MAIN'.runes),
    Token.space('     '.runes),
    Token.comment('; アドレス定数'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('END'.runes),
    Token.eol('\n'.runes),
    Token.eol('\n'.runes),
    Token.label('COUNT1'.runes),
    Token.space('  '.runes),
    Token.op('START'.runes),
    Token.space('                   '.runes),
    Token.comment(';'.runes),
    Token.eol('\n'.runes),
    Token.comment(';       入力    GR1:検索する語'.runes),
    Token.eol('\n'.runes),
    Token.comment(';       処理    GR1中の\'1\'のビットの個数を求める'.runes),
    Token.eol('\n'.runes),
    Token.comment(';       出力    GR0:GR1中の\'1\'のビットの個数'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('PUSH'.runes),
    Token.space('    '.runes),
    Token.dec('0'.runes),
    Token.separation(','.runes),
    Token.gr('GR1'.runes),
    Token.space('           '.runes),
    Token.comment(';'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('PUSH'.runes),
    Token.space('    '.runes),
    Token.dec('0'.runes),
    Token.separation(','.runes),
    Token.gr('GR2'.runes),
    Token.space('           '.runes),
    Token.comment(';'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('SUBA'.runes),
    Token.space('    '.runes),
    Token.gr('GR2'.runes),
    Token.separation(','.runes),
    Token.gr('GR2'.runes),
    Token.space('         '.runes),
    Token.comment('; Count = 0'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('AND'.runes),
    Token.space('     '.runes),
    Token.gr('GR1'.runes),
    Token.separation(','.runes),
    Token.gr('GR1'.runes),
    Token.space('         '.runes),
    Token.comment('; 全部のビットが\'0\'?'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('JZE'.runes),
    Token.space('     '.runes),
    Token.ref('RETURN'.runes),
    Token.space('          '.runes),
    Token.comment('; 全部のビットが\'0\'なら終了'.runes),
    Token.eol('\n'.runes),
    Token.label('MORE'.runes),
    Token.space('    '.runes),
    Token.op('LAD'.runes),
    Token.space('     '.runes),
    Token.gr('GR2'.runes),
    Token.separation(','.runes),
    Token.dec('1'.runes),
    Token.separation(','.runes),
    Token.gr('GR2'.runes),
    Token.space('       '.runes),
    Token.comment('; Count = Count + 1'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('LAD'.runes),
    Token.space('     '.runes),
    Token.gr('GR0'.runes),
    Token.separation(','.runes),
    Token.dec('-1'.runes),
    Token.separation(','.runes),
    Token.gr('GR1'.runes),
    Token.space('      '.runes),
    Token.comment('; 最下位の\'1\'のビット1個を'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('AND'.runes),
    Token.space('     '.runes),
    Token.gr('GR1'.runes),
    Token.separation(','.runes),
    Token.gr('GR0'.runes),
    Token.space('         '.runes),
    Token.comment(';   \'0\'に変える'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('JNZ'.runes),
    Token.space('     '.runes),
    Token.ref('MORE'.runes),
    Token.space('            '.runes),
    Token.comment('; \'1\'のビットが残っていれば繰り返し'.runes),
    Token.eol('\n'.runes),
    Token.label('RETURN'.runes),
    Token.space('  '.runes),
    Token.op('LD'.runes),
    Token.space('      '.runes),
    Token.gr('GR0'.runes),
    Token.separation(','.runes),
    Token.gr('GR2'.runes),
    Token.space('         '.runes),
    Token.comment('; GR0 = Count'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.comment('; LD      GR0,GR1         ; 不要ファイルのコメントアウト例'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('POP'.runes),
    Token.space('     '.runes),
    Token.gr('GR2'.runes),
    Token.space('             '.runes),
    Token.comment(';'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('POP'.runes),
    Token.space('     '.runes),
    Token.gr('GR1'.runes),
    Token.space('             '.runes),
    Token.comment(';'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('RET'.runes),
    Token.space('                     '.runes),
    Token.comment('; 呼び出しプログラムへ戻る'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('END'.runes),
    Token.space('                     '.runes),
    Token.comment(';'.runes),
    Token.eol('\n'.runes),
  ];

  final lexer = Lexer.fromString(input);
  for (final expected in tests) {
    final actual = lexer.nextToken();
    expect('$actual', equals('$expected'));
  }

  final eofToken = lexer.nextToken();
  expect(eofToken.isEof, equals(true));
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
    Token.label('MAIN'.runes),
    Token.space('    '.runes),
    Token.op('START'.runes),
    Token.space('                   '.runes),
    Token.comment('; コメント'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('JUMP'.runes),
    Token.space('    '.runes),
    Token.gr('GR1'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('SUBA'.runes),
    Token.space('    '.runes),
    Token.gr('GR1'.runes),
    Token.separation(','.runes),
    Token.gr('GR1'.runes),
    Token.eol('\n'.runes),
    Token.unexpected('GR1'.runes),
    Token.space('     '.runes),
    Token.op('SUBA'.runes),
    Token.space('    '.runes),
    Token.gr('GR2'.runes),
    Token.separation(','.runes),
    Token.gr('GR2'.runes),
    Token.space('         '.runes),
    Token.comment('; ラベルエラー'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('RET'.runes),
    Token.eol('\n'.runes),
    Token.space('        '.runes),
    Token.op('END'.runes),
    Token.eol('\n'.runes),
  ];

  final lexer = Lexer.fromString(input);
  for (final expected in tests) {
    final actual = lexer.nextToken();
    expect('$actual', equals('$expected'));
  }

  final eofToken = lexer.nextToken();
  expect(eofToken.isEof, equals(true));
}
