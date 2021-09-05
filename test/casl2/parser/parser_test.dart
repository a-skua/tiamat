import 'package:tiamat/src/casl2/ast/ast.dart';
import 'package:tiamat/src/casl2/parser/parser.dart';
import 'package:tiamat/src/casl2/parser/util.dart';
import 'package:tiamat/src/casl2/token/token.dart';
import 'package:tiamat/src/casl2/lexer/lexer.dart';
import 'package:tiamat/src/charcode/charcode.dart';
import 'package:test/test.dart';
import 'dart:math';

void main() {
  test('parse', testPaarse);
  test('to code', testParseNode);
  test('token to code', testTokenToCode);
  test('reg to int', testParseRegToInt);
  test('parse error', testParseError);
}

class ExpectedStatement {
  final String label;
  final String opecode;
  final String operand;

  ExpectedStatement(this.label, this.opecode, this.operand);
}

void testPaarse() {
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
        POP     GR2             ;
        POP     GR1             ;
        RET                     ; 呼び出しプログラムへ戻る
        END                     ;
'''
      .trim()
      .runes
      .toList();

  final parser = Parser.fromLexer(Lexer(input));

  final expected = 'BLOCK('
      'STATEMENT(LABEL(MAIN),OPECODE(START))'
      ','
      'STATEMENT(OPECODE(CALL),OPERAND(IDENT(COUNT1)))'
      ','
      'BLOCK('
      'STATEMENT(OPECODE(LAD),OPERAND(GR(GR1),IDENT(GR1234)))'
      ','
      'STATEMENT(OPECODE(LAD),OPERAND(GR(GR2),DEC(2)))'
      ','
      'STATEMENT(OPECODE(SVC),OPERAND(DEC(1)))'
      ')'
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
      'STATEMENT(OPECODE(PUSH),OPERAND(DEC(0),GR(GR1)))'
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

  final program = parser.parseProgram();
  expect(program.errors.length, equals(0));
  expect(program.toString(), equals(expected));
}

void testParseNode() {
  final input = '''
MAIN    START                   ; コメント
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
        POP     GR2             ;
        POP     GR1             ;
        RET                     ; 呼び出しプログラムへ戻る
        END                     ;
'''
      .trim()
      .runes
      .toList();

  final program = Parser.fromLexer(Lexer(input)).parseProgram();
  final base = Random().nextInt(1 << 10);

  program.env.startPoint = base;

  final tests = <int>[
    // MAIN    START
    //         CALL    COUNT1
    0x8000, 39 + base,
    //         RET
    0x8100,
    //         DC      'hello','world'
    ...'hello'.runes.map((rune) => runeAsCode(rune) ?? 0).toList(),
    ...'world'.runes.map((rune) => runeAsCode(rune) ?? 0).toList(),
    //         DC      'it''s a small world'
    ..."it's a small world".runes.map((rune) => runeAsCode(rune) ?? 0).toList(),
    //         DC      12,-34,56,-78
    12, -34, 56, -78,
    //         DC      #1234,#CDEF
    0x1234, 0xcdef,
    // GR1234  DC      GR1234,MAIN
    37 + base, 0 + base,
    //         END
    // COUNT1  START
    //         PUSH    0,GR1
    0x7001, 0,
    //         PUSH    0,GR2
    0x7002, 0,
    //         SUBA    GR2,GR2
    0x2522,
    //         AND     GR1,GR1
    0x3411,
    //         JZE     RETURN
    0x6300, 54 + base,
    // MORE    LAD     GR2,1,GR2
    0x1222, 1,
    //         LAD     GR0,-1,GR1
    0x1201, -1,
    //         AND     GR1,GR0
    0x3410,
    //         JNZ     MORE
    0x6200, 47 + base,
    // RETURN  LD      GR0,GR2
    0x1402,
    //         POP     GR2
    0x7120,
    //         POP     GR1
    0x7110,
    //         RET
    0x8100,
    //         END
  ];

  final code = program.code;
  expect(code.length, equals(tests.length));
  for (var i = 0; i < tests.length; i += 1) {
    expect(code[i], equals(tests[i]));
  }
}

class TestTokenToCode {
  Token token;
  List<Code> expected;

  TestTokenToCode(this.token, this.expected);
}

void testTokenToCode() {
  final tests = <TestTokenToCode>[
    TestTokenToCode(
      Token(
        "'hello, world'".runes,
        TokenType.string,
      ),
      'hello, world'
          .runes
          .map((rune) => LiteralCode(runeAsCode(rune) ?? 0))
          .toList(),
    ),
    TestTokenToCode(
      Token(
        "'it''s a small world'".runes,
        TokenType.string,
      ),
      "it's a small world"
          .runes
          .map((rune) => LiteralCode(runeAsCode(rune) ?? 0))
          .toList(),
    ),
    TestTokenToCode(
      Token(
        '#FFFF'.runes,
        TokenType.hex,
      ),
      [LiteralCode(0xffff)],
    ),
    TestTokenToCode(
      Token(
        '#0000'.runes,
        TokenType.hex,
      ),
      [LiteralCode(0x0000)],
    ),
    TestTokenToCode(
      Token(
        '-1'.runes,
        TokenType.dec,
      ),
      [LiteralCode(-1)],
    ),
    TestTokenToCode(
      Token(
        '12345'.runes,
        TokenType.dec,
      ),
      [LiteralCode(12345)],
    ),
    TestTokenToCode(
      Token(
        'LABEL'.runes,
        TokenType.ident,
      ),
      [LiteralCode(0)], // FIXME
    ),
  ];

  for (final test in tests) {
    final actual = tokenToCode(test.token, Env());
    final expected = test.expected;
    expect(actual.length, equals(expected.length));
    for (var i = 0; i < actual.length; i += 1) {
      expect(actual[i].value, equals(expected[i].value));
    }
  }
}

class TestParseRegToInt {
  final Token token;
  final int expected;

  TestParseRegToInt(this.token, this.expected);
}

void testParseRegToInt() {
  final tests = [
    TestParseRegToInt(
      Token('GR0'.runes, TokenType.gr),
      0,
    ),
    TestParseRegToInt(
      Token('GR1'.runes, TokenType.gr),
      1,
    ),
    TestParseRegToInt(
      Token('GR2'.runes, TokenType.gr),
      2,
    ),
    TestParseRegToInt(
      Token('GR3'.runes, TokenType.gr),
      3,
    ),
    TestParseRegToInt(
      Token('GR4'.runes, TokenType.gr),
      4,
    ),
    TestParseRegToInt(
      Token('GR5'.runes, TokenType.gr),
      5,
    ),
    TestParseRegToInt(
      Token('GR6'.runes, TokenType.gr),
      6,
    ),
    TestParseRegToInt(
      Token('GR7'.runes, TokenType.gr),
      7,
    ),
  ];

  for (final test in tests) {
    final actual = registerToNumber(test.token);
    expect(actual, equals(test.expected));
  }
}

void testParseError() {
  final input = '''
\tADDA
 SUBA GR1
 ADDL\tGR,GR2
LABEL

        SUBL    R,ADR,GR0
        AND     GR0,ADR,GR0
        AND     GR0,ADR,X
GR1     AND
''';

  final tests = <String>[
    '(line 1) [SYNTAX ERROR] ADDA wrong number of operands. wants 2 or 3 operands.',
    '(line 2) [SYNTAX ERROR] SUBA wrong number of operands. wants 2 or 3 operands.',
    '(line 3) [SYNTAX ERROR] GR is not an expected value. value expects between GR0 and GR7.',
    '(line 4) [SYNTAX ERROR] opecode not found.',
    '(line 6) [SYNTAX ERROR] R is not an expected value. value expects between GR0 and GR7.',
    '(line 7) [SYNTAX ERROR] GR0 is not an expected value. value expects between GR1 and GR7.',
    '(line 8) [SYNTAX ERROR] X is not an expected value. value expects between GR1 and GR7.',
    '(line 9) [SYNTAX ERROR] GR1 cannot be used as label',
  ];
  final program = Parser.fromLexer(Lexer(input.runes.toList())).parseProgram();

  expect(program.errors.length, equals(tests.length));

  for (var i = 0; i < tests.length; i += 1) {
    final actual = program.errors[i].toString();
    final expected = tests[i];

    expect(actual, equals(expected));
  }
}
