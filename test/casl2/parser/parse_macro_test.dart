import 'package:tiamat/src/casl2/parser/parser.dart';
import 'package:tiamat/src/casl2/lexer/lexer.dart';
import 'package:test/test.dart';

void main() {
  test('parse macro', testParseMacro);
}

class _TestParseMacro {
  String input;
  String expected;

  _TestParseMacro(this.input, this.expected);
}

void testParseMacro() {
  final tests = <_TestParseMacro>[
    _TestParseMacro(
      '\tIN BUF,32',
      'BLOCK('
          'BLOCK('
          'STATEMENT(OPECODE(LAD),OPERAND(GR(GR1),IDENT(BUF)))'
          ','
          'STATEMENT(OPECODE(LAD),OPERAND(GR(GR2),DEC(32)))'
          ','
          'STATEMENT(OPECODE(SVC),OPERAND(DEC(1)))'
          ')'
          ')',
    ),
    _TestParseMacro(
      '\tOUT BUF,#0010',
      'BLOCK('
          'BLOCK('
          'STATEMENT(OPECODE(LAD),OPERAND(GR(GR1),IDENT(BUF)))'
          ','
          'STATEMENT(OPECODE(LAD),OPERAND(GR(GR2),HEX(#0010)))'
          ','
          'STATEMENT(OPECODE(SVC),OPERAND(DEC(2)))'
          ')'
          ')',
    ),
    _TestParseMacro(
      '\tRPUSH',
      'BLOCK('
          'BLOCK('
          'STATEMENT(OPECODE(PUSH),OPERAND(DEC(0),GR(GR1)))'
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
    ),
    _TestParseMacro(
      '\tRPOP',
      'BLOCK('
          'BLOCK('
          'STATEMENT(OPECODE(POP),OPERAND(GR(GR7)))'
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
    ),
  ];

  for (final test in tests) {
    final program = Parser(Lexer.fromString(test.input)).parseProgram();

    expect(program.errors.length, equals(0));
    expect(program.toString(), equals(test.expected));
  }
}
