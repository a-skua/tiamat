import 'package:tiamat/src/casl2/lexer/lexer.dart';
import 'package:tiamat/src/casl2/ast/ast.dart';
import 'package:tiamat/src/casl2/parser/parser.dart';
import 'package:tiamat/src/charcode/charcode.dart';
import 'package:test/test.dart';

void main() {
  group('ImplParser', () {
    test('nextNode', testNextNode);
    test('nextNode..code', testParseNode);
  });
}

void testNextNode() {
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
    'Ok(BLOCK('
        'STATEMENT(LABEL(MAIN),OPECODE(START)),'
        'STATEMENT(OPECODE(CALL),OPERAND(REF(COUNT1))),'
        'STATEMENT(OPECODE(IN),OPERAND(REF(GR1234),DEC(2))),'
        'STATEMENT(OPECODE(RET)),'
        'STATEMENT(OPECODE(DC),OPERAND(STRING(\'hello\'),STRING(\'world\'))),'
        'STATEMENT(OPECODE(DC),OPERAND(STRING(\'It\'\'s a small world\'))),'
        'STATEMENT(OPECODE(DC),OPERAND(DEC(12),DEC(-34),DEC(56),DEC(-78))),'
        'STATEMENT(OPECODE(DC),OPERAND(HEX(#1234),HEX(#CDEF))),'
        'STATEMENT(LABEL(GR1234),OPECODE(DC),OPERAND(REF(GR1234),REF(MAIN))),'
        'STATEMENT(OPECODE(END))'
        '))',
    'Ok(BLOCK('
        'STATEMENT(LABEL(COUNT1),OPECODE(START)),'
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
        'STATEMENT(OPECODE(RET)),'
        'STATEMENT(OPECODE(END))'
        '))',
    'Err(L35: [SYNTAX ERROR] Invalid String: \'hello,world)',
    'Ok(())',
  ];

  final parser = ImplParser(ImplLexer.fromString(input));
  final state = State();
  Node? parent;

  for (final expected in expected) {
    final actual = parser.nextNode(parent, state);
    if (actual.isOk) parent = actual.ok;
    expect('$actual', equals(expected));
  }
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
''';

  const base = 100;

  final expected = <List<int>>[
    [
      // MAIN    START
      //         CALL    COUNT1
      0x8000, 39 + base,
      //         RET
      0x8100,
      //         DC      'hello','world'
      ...'hello'.runes.map((rune) => runeAsCode(rune) ?? 0).toList(),
      ...'world'.runes.map((rune) => runeAsCode(rune) ?? 0).toList(),
      //         DC      'it''s a small world'
      ..."it's a small world"
          .runes
          .map((rune) => runeAsCode(rune) ?? 0)
          .toList(),
      //         DC      12,-34,56,-78
      12, -34, 56, -78,
      //         DC      #1234,#CDEF
      0x1234, 0xcdef,
      // GR1234  DC      GR1234,MAIN
      37 + base, 0 + base,
      //         END
    ],
    [
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
    ],
  ];

  final parser = ImplParser(ImplLexer.fromString(input));
  final state = State();
  Node? parent;
  final nodes = <Node>[];

  while (true) {
    final result = parser.nextNode(parent, state);
    expect(result.isOk, equals(true));
    parent = result.ok;
    if (result.ok is EndNode) break;

    nodes.add(result.ok);
  }

  expect(
    nodes.map((n) {
      final result = n.code;
      expect(result.isOk, equals(true));
      return result.ok.map((c) => c.value(base)).toList();
    }).toList(),
    equals(expected),
  );
}