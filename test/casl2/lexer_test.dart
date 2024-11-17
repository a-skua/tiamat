import 'package:tiamat/src/casl2/lexer.dart';
import 'package:tiamat/typedef.dart';
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
    Ok(Token.label('MAIN'.runes)),
    Ok(Token.space('    '.runes)),
    Ok(Token.op('START'.runes)),
    Ok(Token.space('                   '.runes)),
    Ok(Token.comment('; コメント'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('CALL'.runes)),
    Ok(Token.space('    '.runes)),
    Ok(Token.ref('COUNT1'.runes)),
    Ok(Token.space('          '.runes)),
    Ok(Token.comment('; COUNT1呼び出し'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('RET'.runes)),
    Ok(Token.space('     '.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('\t      '.runes)),
    Ok(Token.op('DC'.runes)),
    Ok(Token.space('\t    '.runes)),
    Ok(Token.text("'hello'".runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.text("'world'".runes)),
    Ok(Token.space(' '.runes)),
    Ok(Token.comment('; 文字定数'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('  \t    '.runes)),
    Ok(Token.op('DC'.runes)),
    Ok(Token.space('      '.runes)),
    Ok(Token.text("'It''s a small world'".runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('    \t  '.runes)),
    Ok(Token.op('DC'.runes)),
    Ok(Token.space('      '.runes)),
    Ok(Token.dec('12'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.dec('-34'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.dec('56'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.dec('-78'.runes)),
    Ok(Token.space('   '.runes)),
    Ok(Token.comment('; 10進定数'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('      \t'.runes)),
    Ok(Token.op('DC'.runes)),
    Ok(Token.space('      '.runes)),
    Ok(Token.hex('#1234'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.hex('#CDEF'.runes)),
    Ok(Token.space('     '.runes)),
    Ok(Token.comment('; 16進定数'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.label('GR1234'.runes)),
    Ok(Token.space('  '.runes)),
    Ok(Token.op('DC'.runes)),
    Ok(Token.space('      '.runes)),
    Ok(Token.ref('GR1234'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.ref('MAIN'.runes)),
    Ok(Token.space('     '.runes)),
    Ok(Token.comment('; アドレス定数'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('END'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.label('COUNT1'.runes)),
    Ok(Token.space('  '.runes)),
    Ok(Token.op('START'.runes)),
    Ok(Token.space('                   '.runes)),
    Ok(Token.comment(';'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.comment(';       入力    GR1:検索する語'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.comment(';       処理    GR1中の\'1\'のビットの個数を求める'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.comment(';       出力    GR0:GR1中の\'1\'のビットの個数'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('PUSH'.runes)),
    Ok(Token.space('    '.runes)),
    Ok(Token.dec('0'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.gr('GR1'.runes)),
    Ok(Token.space('           '.runes)),
    Ok(Token.comment(';'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('PUSH'.runes)),
    Ok(Token.space('    '.runes)),
    Ok(Token.dec('0'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.gr('GR2'.runes)),
    Ok(Token.space('           '.runes)),
    Ok(Token.comment(';'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('SUBA'.runes)),
    Ok(Token.space('    '.runes)),
    Ok(Token.gr('GR2'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.gr('GR2'.runes)),
    Ok(Token.space('         '.runes)),
    Ok(Token.comment('; Count = 0'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('AND'.runes)),
    Ok(Token.space('     '.runes)),
    Ok(Token.gr('GR1'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.gr('GR1'.runes)),
    Ok(Token.space('         '.runes)),
    Ok(Token.comment('; 全部のビットが\'0\'?'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('JZE'.runes)),
    Ok(Token.space('     '.runes)),
    Ok(Token.ref('RETURN'.runes)),
    Ok(Token.space('          '.runes)),
    Ok(Token.comment('; 全部のビットが\'0\'なら終了'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.label('MORE'.runes)),
    Ok(Token.space('    '.runes)),
    Ok(Token.op('LAD'.runes)),
    Ok(Token.space('     '.runes)),
    Ok(Token.gr('GR2'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.dec('1'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.gr('GR2'.runes)),
    Ok(Token.space('       '.runes)),
    Ok(Token.comment('; Count = Count + 1'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('LAD'.runes)),
    Ok(Token.space('     '.runes)),
    Ok(Token.gr('GR0'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.dec('-1'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.gr('GR1'.runes)),
    Ok(Token.space('      '.runes)),
    Ok(Token.comment('; 最下位の\'1\'のビット1個を'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('AND'.runes)),
    Ok(Token.space('     '.runes)),
    Ok(Token.gr('GR1'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.gr('GR0'.runes)),
    Ok(Token.space('         '.runes)),
    Ok(Token.comment(';   \'0\'に変える'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('JNZ'.runes)),
    Ok(Token.space('     '.runes)),
    Ok(Token.ref('MORE'.runes)),
    Ok(Token.space('            '.runes)),
    Ok(Token.comment('; \'1\'のビットが残っていれば繰り返し'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.label('RETURN'.runes)),
    Ok(Token.space('  '.runes)),
    Ok(Token.op('LD'.runes)),
    Ok(Token.space('      '.runes)),
    Ok(Token.gr('GR0'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.gr('GR2'.runes)),
    Ok(Token.space('         '.runes)),
    Ok(Token.comment('; GR0 = Count'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.comment('; LD      GR0,GR1         ; 不要ファイルのコメントアウト例'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('POP'.runes)),
    Ok(Token.space('     '.runes)),
    Ok(Token.gr('GR2'.runes)),
    Ok(Token.space('             '.runes)),
    Ok(Token.comment(';'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('POP'.runes)),
    Ok(Token.space('     '.runes)),
    Ok(Token.gr('GR1'.runes)),
    Ok(Token.space('             '.runes)),
    Ok(Token.comment(';'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('RET'.runes)),
    Ok(Token.space('                     '.runes)),
    Ok(Token.comment('; 呼び出しプログラムへ戻る'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('END'.runes)),
    Ok(Token.space('                     '.runes)),
    Ok(Token.comment(';'.runes)),
    Ok(Token.eol('\n'.runes)),
  ];

  final lexer = Lexer.fromString(input);
  for (final expected in tests) {
    final actual = lexer.nextToken();
    expect('$actual', equals('$expected'));
  }

  final eofToken = lexer.nextToken();
  expect(eofToken.isErr, equals(false), reason: 'unexpected error $eofToken');
  expect(eofToken.ok.isEof, equals(true));
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
    Ok(Token.label('MAIN'.runes)),
    Ok(Token.space('    '.runes)),
    Ok(Token.op('START'.runes)),
    Ok(Token.space('                   '.runes)),
    Ok(Token.comment('; コメント'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('JUMP'.runes)),
    Ok(Token.space('    '.runes)),
    Ok(Token.gr('GR1'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('SUBA'.runes)),
    Ok(Token.space('    '.runes)),
    Ok(Token.gr('GR1'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.gr('GR1'.runes)),
    Ok(Token.eol('\n'.runes)),
    Err(TokenizeError(
        'GR1 cannot be used as label', Token.unexpected('GR1'.runes))),
    Ok(Token.space('     '.runes)),
    Ok(Token.op('SUBA'.runes)),
    Ok(Token.space('    '.runes)),
    Ok(Token.gr('GR2'.runes)),
    Ok(Token.separation(','.runes)),
    Ok(Token.gr('GR2'.runes)),
    Ok(Token.space('         '.runes)),
    Ok(Token.comment('; ラベルエラー'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('RET'.runes)),
    Ok(Token.eol('\n'.runes)),
    Ok(Token.space('        '.runes)),
    Ok(Token.op('END'.runes)),
    Ok(Token.eol('\n'.runes)),
  ];

  final lexer = Lexer.fromString(input);
  for (final expected in tests) {
    final actual = lexer.nextToken();
    expect('$actual', equals('$expected'));
  }

  final eofToken = lexer.nextToken();
  expect(eofToken.isErr, equals(false), reason: 'unexpected error $eofToken');
  expect(eofToken.ok.isEof, equals(true));
}
