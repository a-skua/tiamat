import 'package:tiamat/src/casl2/parser/parser.dart';
import 'package:tiamat/src/casl2/lexer/lexer.dart';
import 'package:test/test.dart';

void main() {
  test('parse macro', testParseMacro);
}

class _TestParseMacro {
  String input;
  String expected;
  List<int> expectedCode;
  int expectedSize;

  _TestParseMacro({
    required this.input,
    required this.expected,
    required this.expectedCode,
    required this.expectedSize,
  });
}

void testParseMacro() {
  final tests = <_TestParseMacro>[
    _TestParseMacro(
      input: 'LABEL IN BUF,32',
      expected: 'BLOCK('
          'BLOCK('
          'STATEMENT(LABEL(LABEL),OPECODE(LAD),OPERAND(GR(GR1),IDENT(BUF)))'
          ','
          'STATEMENT(OPECODE(LAD),OPERAND(GR(GR2),DEC(32)))'
          ','
          'STATEMENT(OPECODE(SVC),OPERAND(DEC(1)))'
          ')'
          ')',
      expectedCode: [0x1210, 0, 0x1220, 32, 0xf000, 1],
      expectedSize: 6,
    ),
    _TestParseMacro(
      input: 'LABEL OUT BUF,#0010',
      expected: 'BLOCK('
          'BLOCK('
          'STATEMENT(LABEL(LABEL),OPECODE(LAD),OPERAND(GR(GR1),IDENT(BUF)))'
          ','
          'STATEMENT(OPECODE(LAD),OPERAND(GR(GR2),HEX(#0010)))'
          ','
          'STATEMENT(OPECODE(SVC),OPERAND(DEC(2)))'
          ')'
          ')',
      expectedCode: [0x1210, 0, 0x1220, 0x10, 0xf000, 2],
      expectedSize: 6,
    ),
    _TestParseMacro(
      input: 'LABEL RPUSH',
      expected: 'BLOCK('
          'BLOCK('
          'STATEMENT(LABEL(LABEL),OPECODE(PUSH),OPERAND(DEC(0),GR(GR1)))'
          ','
          'STATEMENT(OPECODE(PUSH),OPERAND(DEC(0),GR(GR2)))'
          ','
          'STATEMENT(OPECODE(PUSH),OPERAND(DEC(0),GR(GR3)))'
          ','
          'STATEMENT(OPECODE(PUSH),OPERAND(DEC(0),GR(GR4)))'
          ','
          'STATEMENT(OPECODE(PUSH),OPERAND(DEC(0),GR(GR5)))'
          ','
          'STATEMENT(OPECODE(PUSH),OPERAND(DEC(0),GR(GR6)))'
          ','
          'STATEMENT(OPECODE(PUSH),OPERAND(DEC(0),GR(GR7)))'
          ')'
          ')',
      expectedCode: [
        0x7001,
        0,
        0x7002,
        0,
        0x7003,
        0,
        0x7004,
        0,
        0x7005,
        0,
        0x7006,
        0,
        0x7007,
        0
      ],
      expectedSize: 14,
    ),
    _TestParseMacro(
      input: 'LABEL RPOP',
      expected: 'BLOCK('
          'BLOCK('
          'STATEMENT(LABEL(LABEL),OPECODE(POP),OPERAND(GR(GR7)))'
          ','
          'STATEMENT(OPECODE(POP),OPERAND(GR(GR6)))'
          ','
          'STATEMENT(OPECODE(POP),OPERAND(GR(GR5)))'
          ','
          'STATEMENT(OPECODE(POP),OPERAND(GR(GR4)))'
          ','
          'STATEMENT(OPECODE(POP),OPERAND(GR(GR3)))'
          ','
          'STATEMENT(OPECODE(POP),OPERAND(GR(GR2)))'
          ','
          'STATEMENT(OPECODE(POP),OPERAND(GR(GR1)))'
          ')'
          ')',
      expectedCode: [0x7170, 0x7160, 0x7150, 0x7140, 0x7130, 0x7120, 0x7110],
      expectedSize: 7,
    ),
  ];

  for (final test in tests) {
    final program = Parser(Lexer.fromString(test.input)).parseProgram();

    expect(program.errors.length, equals(0));
    expect(program.toString(), equals(test.expected));
    expect(program.size, equals(test.expectedSize));
    expect(program.code, equals(test.expectedCode));
  }
}
