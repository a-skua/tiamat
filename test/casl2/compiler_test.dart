import 'package:tiamat/src/casl2/lexer/token.dart';
import 'package:tiamat/src/casl2/compiler.dart';
import 'package:tiamat/src/casl2/parser/ast.dart';
import 'package:test/test.dart';

void main() {
  group('Compiler', () {
    group('compile()', () {
      test('ok', testCompilerCompile);
    });
  });
}

void testCompilerCompile() {
  final tests = [
    (
      'LAD GR1,1',
      Statement(
        Token.op('LAD'.runes),
        operand: [Token.gr('GR1'.runes), Token.dec('1'.runes)],
      ),
      'Ok((WORDS(CONST(${0x1210}),CONST(${0x0001}))))',
    ),
    (
      'FOO LAD GR1,1,GR2',
      Statement(
        Token.op('LAD'.runes),
        operand: [
          Token.gr('GR1'.runes),
          Token.dec('1'.runes),
          Token.gr('GR2'.runes)
        ],
        label: Token.label('FOO'.runes),
      ),
      'Ok((LABEL(FOO),REFS(FOO=CONST(${0x1212})),WORDS(CONST(${0x1212}),CONST(${0x0001}))))',
    ),
    (
      '; STARTラベルが設定されているケース\n'
          'MAIN   START FOO\n'
          '       NOP\n'
          '       NOP\n'
          'FOO    LAD   GR1,1,GR2\n'
          '       NOP\n'
          'EXIT   RET\n'
          '       END',
      Subroutine(
        Statement(
          Token.op('START'.runes),
          label: Token.label('MAIN'.runes),
          operand: [Token.ref('FOO'.runes)],
        ),
        [
          Statement(Token.op('NOP'.runes)),
          Statement(Token.op('NOP'.runes)),
          Statement(
            Token.op('LAD'.runes),
            operand: [
              Token.gr('GR1'.runes),
              Token.dec('1'.runes),
              Token.gr('GR2'.runes)
            ],
            label: Token.label('FOO'.runes),
          ),
          Statement(Token.op('NOP'.runes)),
          Statement(
            Token.op('RET'.runes),
            label: Token.label('EXIT'.runes),
          ),
        ],
      ),
      'Ok(('
          'LABEL(MAIN),'
          'REFS(FOO=CONST(${0x1212}),MAIN=CONST(${0x1212}),EXIT=CONST(${0x8100})),'
          'WORDS(CONST(0),CONST(0),CONST(${0x1212}),CONST(${0x0001}),CONST(0),CONST(${0x8100}))'
          '))',
    ),
    (
      '; STARTラベルが設定されていないケース\n'
          'MAIN   START\n'
          '       NOP\n'
          '       NOP\n'
          'FOO    LAD   GR1,1,GR2\n'
          '       NOP\n'
          'EXIT   RET\n'
          '       END',
      Subroutine(
        Statement(
          Token.op('START'.runes),
          label: Token.label('MAIN'.runes),
        ),
        [
          Statement(Token.op('NOP'.runes)),
          Statement(Token.op('NOP'.runes)),
          Statement(
            Token.op('LAD'.runes),
            operand: [
              Token.gr('GR1'.runes),
              Token.dec('1'.runes),
              Token.gr('GR2'.runes)
            ],
            label: Token.label('FOO'.runes),
          ),
          Statement(Token.op('NOP'.runes)),
          Statement(
            Token.op('RET'.runes),
            label: Token.label('EXIT'.runes),
          ),
        ],
      ),
      'Ok(('
          'LABEL(MAIN),'
          'REFS(MAIN=CONST(0),FOO=CONST(${0x1212}),EXIT=CONST(${0x8100})),'
          'WORDS(CONST(0),CONST(0),CONST(${0x1212}),CONST(${0x0001}),CONST(0),CONST(${0x8100}))'
          '))',
    ),
  ];

  final compiler = Compiler();

  for (final (reason, stmt, expected) in tests) {
    expect('${compiler.compile(stmt)}', equals(expected), reason: reason);
  }
}
