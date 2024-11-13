import 'package:tiamat/src/casl2/casl2.dart';
import 'package:tiamat/src/charcode/charcode.dart';
import 'package:test/test.dart';
import 'dart:math';

void main() {
  group('compile', () {
    test('base 0', testParseNode);
    test('base rand', () => testParseNode(Random().nextInt(1 << 10)));
    test('parse macro with label', testParseMacroWithLabel);
    test('error: unscoped label', testUnscopedLabel);
  });
}

void testUnscopedLabel() {
  final input = '''
MAIN    START                   ; コメント
        CALL    COUNT1          ; COUNT1呼び出し
        JUMP RETURN             ; エラー!
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

  final result = Casl2.fromString(input).compile();
  expect(result.isErr, equals(true));
}

void testParseMacroWithLabel() {
  final base = 100;
  final input = '''
MAIN    START
        LAD     GR1,5
        LAD     GR2,0
LOOP    LAD     GR2,1,GR2
        CPL     GR2,GR1
        JZE     BREAK
        JUMP    LOOP
BREAK   OUT     OUTBUF,5
        IN      INBUF,32
        RPUSH
        RPOP
        NOP
        RET
OUTBUF  DC      '12345'
INBUF   DS      32
        END
''';

  final expected = <int>[
    // LAD GR1,5
    0x1210, // 0
    5,
    // LAD GR2,0
    0x1220, // 2
    0,
    // LAD GR2,1,GR2
    0x1222, // 4
    1,
    // CPL GR2,GR1
    0x4521, // 6
    // JZE BREAK
    0x6300,
    base + 11, // 8
    0x6400,
    // OUT OUTBUF,5
    base + 4, // 10
    0x1210,
    base + 46, // 12
    0x1220,
    5, // 14
    0xf000,
    2, // 16
    // IN INBUF,32
    0x1210,
    base + 51, // 18
    0x1220,
    32, // 20
    0xf000,
    1, // 22
    // RPUSH
    0x7001,
    0, // 24
    0x7002,
    0, // 26
    0x7003,
    0, // 28
    0x7004,
    0, // 30
    0x7005,
    0, // 32
    0x7006,
    0, // 34
    0x7007,
    0, // 36
    // RPOP
    0x7170,
    0x7160, // 38
    0x7150,
    0x7140, // 40
    0x7130,
    0x7120, // 42
    0x7110,
    // NOP
    0, // 44
    // RET
    0x8100,
    // DC '12345'
    ...'12345'.runes.map((rune) => runeAsCode(rune) ?? 0).toList(), // 46
    // DS 37
    ...List.generate(32, (_) => 0), // 51
  ];

  final result = Casl2.fromString(input).compile();
  expect(result.isOk, equals(true));
  expect(result.ok.map((c) => c.value(base)).toList(), equals(expected));
}

void testParseNode([final int base = 0]) {
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
      .trim();

  final expected = <int>[
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

  final result = Casl2.fromString(input).compile();
  expect(result.isOk, equals(true));
  expect(result.ok.map((c) => c.value(base)).toList(), equals(expected));
}
