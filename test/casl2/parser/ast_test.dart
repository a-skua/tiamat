import 'package:tiamat/src/casl2/lexer/token.dart';
import 'package:tiamat/src/casl2/parser/ast.dart';
import 'package:test/test.dart';

void main() {
  group('Statement', () {
    test('label', testStatementLabel);
    test('opecode', testStatementOpecode);
    test('operand', testStatementOperand);
    test('toString', testStatementToString);
  });

  group('Macro', () {
    test('label', testMacroLabel);
    test('opecode', testMacroOpecode);
    test('operand', testMacroOperand);
    test('toString', testMacroToString);
  });

  group('Subroutine', () {
    test('label', testSubroutineLabel);
    test('opecode', testSubroutineOpecode);
    test('operand', testSubroutineOperand);
    test('toString', testSubroutineToString);
  });
}

void testStatementLabel() {
  final tests = [
    (
      Statement(Token.op('START'.runes), label: Token.label('FOO'.runes)),
      Token.label('FOO'.runes),
    ),
    (
      Statement(Token.op('START'.runes)),
      null,
    ),
  ];

  for (final (stmt, expected) in tests) {
    expect(stmt.label, equals(expected));
  }
}

void testStatementOpecode() {
  final tests = [
    (
      Statement(Token.op('START'.runes)),
      Token.op('START'.runes),
    ),
    (
      Statement(Token.op('RET'.runes)),
      Token.op('RET'.runes),
    ),
  ];

  for (final (stmt, expected) in tests) {
    expect(stmt.opecode, equals(expected));
  }
}

void testStatementOperand() {
  final tests = [
    (
      Statement(Token.op('START'.runes)),
      [],
    ),
    (
      Statement(Token.op('ADDA'.runes),
          operand: [Token.gr('GR0'.runes), Token.dec('0'.runes)]),
      [Token.gr('GR0'.runes), Token.dec('0'.runes)],
    ),
  ];

  for (final (stmt, expected) in tests) {
    expect(stmt.operand, equals(expected));
  }
}

void testStatementToString() {
  final tests = [
    (
      Statement(Token.op('RET'.runes)),
      'STATEMENT(OPECODE(RET))',
    ),
    (
      Statement(Token.op('RET'.runes), label: Token.label('FOO'.runes)),
      'STATEMENT(LABEL(FOO),OPECODE(RET))'
    ),
    (
      Statement(Token.op('ADDA'.runes),
          operand: [Token.gr('GR0'.runes), Token.dec('0'.runes)]),
      'STATEMENT(OPECODE(ADDA),OPERAND(GR(GR0),DEC(0)))'
    ),
  ];

  for (final (stmt, expected) in tests) {
    expect('$stmt', equals(expected));
  }
}

void testMacroLabel() {
  final tests = [
    (
      Macro(Token.op('IN'.runes)),
      null,
    ),
    (
      Macro(Token.op('IN'.runes), label: Token.label('FOO'.runes)),
      Token.label('FOO'.runes),
    ),
  ];

  for (final (stmt, expected) in tests) {
    expect(stmt.label, equals(expected));
  }
}

void testMacroOpecode() {
  final tests = [
    (
      Macro(Token.op('IN'.runes)),
      Token.op('IN'.runes),
    ),
    (
      Macro(Token.op('OUT'.runes)),
      Token.op('OUT'.runes),
    ),
  ];

  for (final (stmt, expected) in tests) {
    expect(stmt.opecode, equals(expected));
  }
}

void testMacroOperand() {
  final tests = [
    (
      Macro(Token.op('IN'.runes)),
      [],
    ),
    (
      Macro(Token.op('IN'.runes),
          operand: [Token.ref('IBUF'.runes), Token.ref('LEN'.runes)]),
      [Token.ref('IBUF'.runes), Token.ref('LEN'.runes)],
    ),
  ];

  for (final (stmt, expected) in tests) {
    expect(stmt.operand, equals(expected));
  }
}

void testMacroToString() {
  final tests = [
    (
      Macro(Token.op('IN'.runes)),
      'MACRO(OPECODE(IN))',
    ),
    (
      Macro(Token.op('IN'.runes), label: Token.label('FOO'.runes)),
      'MACRO(LABEL(FOO),OPECODE(IN))'
    ),
    (
      Macro(Token.op('IN'.runes),
          operand: [Token.ref('IBUF'.runes), Token.ref('LEN'.runes)]),
      'MACRO(OPECODE(IN),OPERAND(REF(IBUF),REF(LEN)))'
    ),
  ];

  for (final (stmt, expected) in tests) {
    expect('$stmt', equals(expected));
  }
}

void testSubroutineLabel() {
  final tests = [
    (
      Subroutine(
          Statement(Token.op('START'.runes), label: Token.label('FOO'.runes)),
          []),
      Token.label('FOO'.runes),
    ),
    (
      Subroutine(Statement(Token.op('START'.runes)), []),
      null,
    ),
  ];

  for (final (stmt, expected) in tests) {
    expect(stmt.label, equals(expected));
  }
}

void testSubroutineOpecode() {
  final tests = [
    (
      Subroutine(Statement(Token.op('START'.runes)), []),
      Token.op('START'.runes),
    ),
  ];

  for (final (stmt, expected) in tests) {
    expect(stmt.opecode, equals(expected));
  }
}

void testSubroutineOperand() {
  final tests = [
    (
      Subroutine(Statement(Token.op('START'.runes)), []),
      [],
    ),
    (
      Subroutine(
        Statement(Token.op('START'.runes), operand: [Token.ref('FOO'.runes)]),
        [],
      ),
      [Token.ref('FOO'.runes)],
    ),
  ];

  for (final (stmt, expected) in tests) {
    expect(stmt.operand, equals(expected));
  }
}

void testSubroutineToString() {
  final tests = [
    (
      Subroutine(
        Statement(Token.op('START'.runes)),
        [
          Statement(Token.op('ADDA'.runes),
              operand: [Token.gr('GR0'.runes), Token.dec('0'.runes)]),
          Statement(Token.op('RET'.runes)),
        ],
      ),
      'SUBROUTINE(PROCESS(STATEMENT(OPECODE(ADDA),OPERAND(GR(GR0),DEC(0))),STATEMENT(OPECODE(RET))))',
    ),
    (
      Subroutine(
        Statement(Token.op('START'.runes), label: Token.label('FOO'.runes)),
        [
          Statement(Token.op('RET'.runes)),
        ],
      ),
      'SUBROUTINE(LABEL(FOO),PROCESS(STATEMENT(OPECODE(RET))))'
    ),
    (
      Subroutine(
        Statement(Token.op('START'.runes), operand: [Token.ref('FOO'.runes)]),
        [
          Statement(Token.op('ADDA'.runes),
              operand: [Token.gr('GR0'.runes), Token.dec('0'.runes)]),
          Statement(Token.op('RET'.runes), label: Token.label('FOO'.runes)),
        ],
      ),
      'SUBROUTINE(START(REF(FOO)),PROCESS(STATEMENT(OPECODE(ADDA),OPERAND(GR(GR0),DEC(0))),STATEMENT(LABEL(FOO),OPECODE(RET))))'
    ),
  ];

  for (final (stmt, expected) in tests) {
    expect('$stmt', equals(expected));
  }
}
