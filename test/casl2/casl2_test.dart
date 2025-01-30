import 'package:tiamat/casl2.dart';
import 'package:tiamat/src/casl2/charcode.dart' show RuneToReal;
import 'package:tiamat/typedef.dart';
import 'package:test/test.dart';

void main() {
  group('Casl2', () {
    group('parse()', () {
      test('ok', testCasl2ParseOk);
    });

    group('build()', () {
      test('ok 1', testCasl2BuildOk1);
      test('ok 2', testCasl2BuildOk2);
      test('ok 3', testCasl2BuildOk3);
      test('err: unscoped label', testCasl2BuildErrUnscopedLabel);
    });
  });

  group('Module', () {});
  // TODO
}

void testCasl2ParseOk() {
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

  final actual = Casl2.fromString(input).parse();

  final expected = Ok([
    Subroutine(
      Statement(
        Token.op('START'.runes),
        label: Token.label('MAIN'.runes),
      ),
      [
        Statement(
          Token.op('CALL'.runes),
          operand: [Token.ref('COUNT1'.runes)],
        ),
        Statement(
          Token.op('RET'.runes),
        ),
        Statement(
          Token.op('DC'.runes),
          operand: [
            Token.text("'hello'".runes),
            Token.text("'world'".runes),
          ],
        ),
        Statement(
          Token.op('DC'.runes),
          operand: [Token.text("'it''s a small world'".runes)],
        ),
        Statement(
          Token.op('DC'.runes),
          operand: [
            Token.dec('12'.runes),
            Token.dec('-34'.runes),
            Token.dec('56'.runes),
            Token.dec('-78'.runes)
          ],
        ),
        Statement(
          Token.op('DC'.runes),
          operand: [Token.hex('#1234'.runes), Token.hex('#CDEF'.runes)],
        ),
        Statement(
          Token.op('DC'.runes),
          operand: [Token.ref('GR1234'.runes), Token.ref('MAIN'.runes)],
          label: Token.label('GR1234'.runes),
        ),
      ],
    ),
    Subroutine(
      Statement(Token.op('START'.runes), label: Token.label('COUNT1'.runes)),
      [
        Statement(
          Token.op('PUSH'.runes),
          operand: [Token.dec('0'.runes), Token.gr('GR1'.runes)],
        ),
        Statement(
          Token.op('PUSH'.runes),
          operand: [Token.dec('0'.runes), Token.gr('GR2'.runes)],
        ),
        Statement(
          Token.op('SUBA'.runes),
          operand: [Token.gr('GR2'.runes), Token.gr('GR2'.runes)],
        ),
        Statement(
          Token.op('AND'.runes),
          operand: [Token.gr('GR1'.runes), Token.gr('GR1'.runes)],
        ),
        Statement(
          Token.op('JZE'.runes),
          operand: [Token.ref('RETURN'.runes)],
        ),
        Statement(
          Token.op('LAD'.runes),
          operand: [
            Token.gr('GR2'.runes),
            Token.dec('1'.runes),
            Token.gr('GR2'.runes)
          ],
          label: Token.label('MORE'.runes),
        ),
        Statement(
          Token.op('LAD'.runes),
          operand: [
            Token.gr('GR0'.runes),
            Token.dec('-1'.runes),
            Token.gr('GR1'.runes)
          ],
        ),
        Statement(
          Token.op('AND'.runes),
          operand: [Token.gr('GR1'.runes), Token.gr('GR0'.runes)],
        ),
        Statement(
          Token.op('JNZ'.runes),
          operand: [Token.ref('MORE'.runes)],
        ),
        Statement(
          Token.op('LD'.runes),
          operand: [Token.gr('GR0'.runes), Token.gr('GR2'.runes)],
          label: Token.label('RETURN'.runes),
        ),
        Statement(
          Token.op('POP'.runes),
          operand: [Token.gr('GR2'.runes)],
        ),
        Statement(
          Token.op('POP'.runes),
          operand: [Token.gr('GR1'.runes)],
        ),
        Statement(
          Token.op('RET'.runes),
        ),
      ],
    ),
  ]);

  expect('$actual', equals('$expected'));
}

void testCasl2BuildErrUnscopedLabel() {
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

  final expected = Err([
    CompileError.fromToken(
      '[ERROR] UNKNOWN LABEL=RETURN',
      Token.op('JUMP'.runes, lineNumber: 3),
    ),
  ]);

  final actual = Casl2.fromString(input).build();
  expect(
    '$actual',
    equals('$expected'),
  );
}

void testCasl2BuildOk1() {
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

  final expected = Ok(Module({
    'MAIN': 0,
  }, [
    // [MAIN] LAD GR1,5
    0x1210, 5, // 0
    // LAD GR2,0
    0x1220, 0, // 2
    // [LOOP] LAD GR2,1,GR2
    0x1222, 1, // 4
    // CPL GR2,GR1
    0x4521, // 5
    // JZE [BREAK]
    0x6300, 11, // 7
    // JUMP [LOOP]
    0x6400, 4, // 9
    // [BREAK] OUT [OUTBUF],5
    0x1210, 46, // 11
    0x1220, 5, // 13
    0xf000, 2, // 15
    // IN [INBUF],32
    0x1210, 51, // 17
    0x1220, 32, // 19
    0xf000, 1, // 21
    // RPUSH
    0x7001, 0, // 23
    0x7002, 0, // 25
    0x7003, 0, // 27
    0x7004, 0, // 29
    0x7005, 0, // 31
    0x7006, 0, // 33
    0x7007, 0, // 35
    // RPOP
    0x7170, // 37
    0x7160, // 38
    0x7150, // 39
    0x7140, // 40
    0x7130, // 41
    0x7120, // 42
    0x7110, // 43
    // NOP
    0, // 44
    // RET
    0x8100, // 45
    // [OUTBUF] DC '12345'
    ...'12345'.runes.map((rune) => rune.real), // 46
    // [INBUF] DS 32
    ...List.generate(32, (_) => 0), // 51
  ]));

  final actual = Casl2.fromString(input).build();
  expect('$actual', equals('$expected'));
}

void testCasl2BuildOk2() {
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

  final expected = Ok(Module({
    'MAIN': 0,
    'COUNT1': 39,
  }, [
    // MAIN    START
    //         CALL    COUNT1
    0x8000, 39, // 0
    //         RET
    0x8100, // 2
    //         DC      'hello','world'
    ...'hello'.runes.map((rune) => rune.real), // 3
    ...'world'.runes.map((rune) => rune.real), // 8
    //         DC      'it''s a small world'
    ..."it's a small world".runes.map((rune) => rune.real), // 13
    //         DC      12,-34,56,-78
    12, -34, 56, -78, // 31
    //         DC      #1234,#CDEF
    0x1234, 0xcdef, // 35
    // GR1234  DC      GR1234,MAIN
    37, 0, // 37
    //         END
    // COUNT1  START
    //         PUSH    0,GR1
    0x7001, 0, // 39
    //         PUSH    0,GR2
    0x7002, 0,
    //         SUBA    GR2,GR2
    0x2522,
    //         AND     GR1,GR1
    0x3411,
    //         JZE     RETURN
    0x6300, 54,
    // MORE    LAD     GR2,1,GR2
    0x1222, 1,
    //         LAD     GR0,-1,GR1
    0x1201, -1,
    //         AND     GR1,GR0
    0x3410,
    //         JNZ     MORE
    0x6200, 47,
    // RETURN  LD      GR0,GR2
    0x1402,
    //         POP     GR2
    0x7120,
    //         POP     GR1
    0x7110,
    //         RET
    0x8100,
    //         END
  ]));

  final actual = Casl2.fromString(input).build();
  expect('$actual', equals('$expected'));
}

void testCasl2BuildOk3() {
  final input = '''
MAIN    START   FOO             ; コメント
        CALL    COUNT1          ; COUNT1呼び出し
FOO     RET
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

  final expected = Ok(Module({
    'MAIN': 2,
    'COUNT1': 39,
  }, [
    // MAIN    START
    //         CALL    COUNT1
    0x8000, 39, // 0
    //         RET
    0x8100, // 2
    //         DC      'hello','world'
    ...'hello'.runes.map((rune) => rune.real), // 3
    ...'world'.runes.map((rune) => rune.real), // 8
    //         DC      'it''s a small world'
    ..."it's a small world".runes.map((rune) => rune.real), // 13
    //         DC      12,-34,56,-78
    12, -34, 56, -78, // 31
    //         DC      #1234,#CDEF
    0x1234, 0xcdef, // 35
    // GR1234  DC      GR1234,MAIN
    37, 2, // 37
    //         END
    // COUNT1  START
    //         PUSH    0,GR1
    0x7001, 0, // 39
    //         PUSH    0,GR2
    0x7002, 0,
    //         SUBA    GR2,GR2
    0x2522,
    //         AND     GR1,GR1
    0x3411,
    //         JZE     RETURN
    0x6300, 54,
    // MORE    LAD     GR2,1,GR2
    0x1222, 1,
    //         LAD     GR0,-1,GR1
    0x1201, -1,
    //         AND     GR1,GR0
    0x3410,
    //         JNZ     MORE
    0x6200, 47,
    // RETURN  LD      GR0,GR2
    0x1402,
    //         POP     GR2
    0x7120,
    //         POP     GR1
    0x7110,
    //         RET
    0x8100,
    //         END
  ]));

  final actual = Casl2.fromString(input).build();
  expect('$actual', equals('$expected'));
}
