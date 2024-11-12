import 'package:tiamat/src/casl2/token/token.dart';
import 'package:tiamat/src/casl2/typedef.dart';
import 'package:tiamat/src/casl2/ast/ast.dart';
import 'package:tiamat/src/casl2/parser/parser.dart';
import 'package:test/test.dart';

void main() {
  group('Code', () {
    test('value', testCodeValue);
  });

  group('Statement', () {
    test('label', testStatementLabel);
    test('opecode', testStatementOpecode);
    test('operand', testStatementOperand);
    test('toString', testStatementToString);

    test('code', testStatementNodeCode, skip: true);
    test('size', testStatementNodeSize, skip: true);
    test('position', testStatementNodePosition, skip: true);
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

  group('Module', () {
    test('toString', testModuleToString);
  });
}

void testCodeValue() {
  expect(Code((base) => base + 50).value(), equals(50));
  expect(Code((base) => base + 50).value(100), equals(150));
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

void testStatementNodeCode() {
  final label = Token.label('FOO'.runes);
  final opecode = Token.op('START'.runes);
  final operand = [Token.dec('1'.runes)];

  final code = Result<List<Code>, ParseError>.ok([
    Code((_) => 1),
    Code((_) => 2),
    Code((_) => 3),
  ]);

  expect(
      // TODO
      Statement(opecode, label: label, operand: operand),
      equals(code));
}

void testStatementNodeSize() {
  final label = Token.label('FOO'.runes);
  final opecode = Token.op('START'.runes);
  final operand = [Token.dec('1'.runes)];

  expect(
      // TODO
      Statement(opecode, label: label, operand: operand),
      equals(0));

  expect(
      // TODO
      Statement(opecode, label: label, operand: operand),
      equals(0));

  expect(
      // TODO
      Statement(opecode, label: label, operand: operand),
      equals(3));
}

void testStatementNodePosition() {
  final label = Token.label('FOO'.runes);
  final opecode = Token.op('START'.runes);
  final operand = [Token.dec('1'.runes)];

  expect(
      // TODO
      Statement(opecode, label: label, operand: operand),
      equals(0));

  expect(
      // TODO
      Statement(opecode, label: label, operand: operand),
      equals(6));
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

void testModuleToString() {
  final tests = [
    (
      Module([
        Subroutine(
          Statement(Token.op('START'.runes), label: Token.label('FOO'.runes)),
          [Statement(Token.op('RET'.runes))],
        ),
        Statement(Token.op('DC'.runes), operand: [Token.text("'FOO'".runes)]),
      ]),
      "MODULE(SUBROUTINE(LABEL(FOO),PROCESS(STATEMENT(OPECODE(RET)))),STATEMENT(OPECODE(DC),OPERAND(TEXT('FOO'))))"
    ),
  ];

  for (final (mod, expected) in tests) {
    expect('$mod', equals(expected));
  }
}