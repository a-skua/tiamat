import 'package:tiamat/src/casl2/token/token.dart';
import 'package:tiamat/src/casl2/typedef.dart';
import 'package:tiamat/src/casl2/ast/ast.dart';
import 'package:test/test.dart';

void main() {
  group('Code', () {
    test('value', testCodeValue);
  });

  group('StatementNode', () {
    test('label', testStatementNodeLabel);
    test('code', testStatementNodeCode);
    test('size', testStatementNodeSize);
    test('position', testStatementNodePosition);
    test('toString', testStatementNodeToString);
  });

  group('MacroNode', () {
    test('toString', testMacroNodeToString);
  });

  group('SubroutineNode', () {
    test('toString', testSubroutineNodeToString);
  });

  group('ModuleNode', () {
    test('toString', testModuleNodeToString);
  });
}

// mock
Result<List<Code>, ParseError> parser(
  Node? parent,
  Token? label,
  Token opecode,
  List<Token> operand,
) =>
    Result.ok([]);

void testCodeValue() {
  expect(Code((base) => base + 50).value(), equals(50));
  expect(Code((base) => base + 50).value(100), equals(150));
}

void testStatementNodeLabel() {
  expect(
      StatementNode(null, Token('FOO'.runes, TokenType.label),
              Token('START'.runes, TokenType.opecode), [], parser)
          .label,
      equals('FOO'));
  expect(
      StatementNode(
              null, null, Token('START'.runes, TokenType.opecode), [], parser)
          .label,
      equals(null));
}

void testStatementNodeCode() {
  final parent = StatementNode(
    null,
    null,
    Token('START'.runes, TokenType.opecode),
    [],
    parser,
  );
  final label = Token('FOO'.runes, TokenType.label);
  final opecode = Token('START'.runes, TokenType.opecode);
  final operand = [
    Token('1'.runes, TokenType.dec),
  ];

  final code = Result<List<Code>, ParseError>.ok([
    Code((_) => 1),
    Code((_) => 2),
    Code((_) => 3),
  ]);

  expect(
      StatementNode(parent, label, opecode, operand,
          (actualParent, actualLabel, actualOpecode, actualOperand) {
        expect(actualParent, equals(parent));
        expect(actualLabel, equals(label));
        expect(actualOpecode, equals(opecode));
        expect(actualOperand, equals(operand));
        return code;
      }).code,
      equals(code));
}

void testStatementNodeSize() {
  final parent = StatementNode(
    null,
    null,
    Token('START'.runes, TokenType.opecode),
    [],
    parser,
  );
  final label = Token('FOO'.runes, TokenType.label);
  final opecode = Token('START'.runes, TokenType.opecode);
  final operand = [
    Token('1'.runes, TokenType.dec),
  ];

  expect(
      StatementNode(parent, label, opecode, operand,
          (parent, label, opecode, operand) => Result.ok([])).size,
      equals(0));

  expect(
      StatementNode(
          parent,
          label,
          opecode,
          operand,
          (parent, label, opecode, operand) => Result.err(ParseError(
                'TEST',
                start: 0,
                end: 0,
                lineStart: 0,
                lineNumber: 1,
              ))).size,
      equals(0));

  expect(
      StatementNode(
          parent,
          label,
          opecode,
          operand,
          (parent, label, opecode, operand) => Result.ok([
                Code((_) => 1),
                Code((_) => 2),
                Code((_) => 3),
              ])).size,
      equals(3));
}

void testStatementNodePosition() {
  final label = Token('FOO'.runes, TokenType.label);
  final opecode = Token('START'.runes, TokenType.opecode);
  final operand = [
    Token('1'.runes, TokenType.dec),
  ];

  expect(
      StatementNode(
          null,
          label,
          opecode,
          operand,
          (parent, label, opecode, operand) => Result.ok([
                Code((_) => 1),
                Code((_) => 2),
                Code((_) => 3),
              ])).position,
      equals(0));

  final parent = StatementNode(
      StatementNode(
          null,
          null,
          Token('START'.runes, TokenType.opecode),
          [],
          (parent, label, opecode, operand) => Result.ok([
                Code((_) => 1),
                Code((_) => 2),
                Code((_) => 3),
              ])),
      null,
      Token('START'.runes, TokenType.opecode),
      [],
      (parent, label, opecode, operand) => Result.ok([
            Code((_) => 1),
            Code((_) => 2),
            Code((_) => 3),
          ]));

  expect(
      StatementNode(
          parent,
          label,
          opecode,
          operand,
          (parent, label, opecode, operand) => Result.ok([
                Code((_) => 1),
                Code((_) => 2),
                Code((_) => 3),
              ])).position,
      equals(6));
}

void testStatementNodeToString() {
  final tests = [
    [
      StatementNode(
          null, null, Token('RET'.runes, TokenType.opecode), [], parser),
      'STATEMENT(OPECODE(RET))'
    ],
    [
      StatementNode(null, Token('FOO'.runes, TokenType.label),
          Token('RET'.runes, TokenType.opecode), [], parser),
      'STATEMENT(LABEL(FOO),OPECODE(RET))'
    ],
    [
      StatementNode(
          null,
          null,
          Token('ADDA'.runes, TokenType.opecode),
          [Token('GR0'.runes, TokenType.gr), Token('0'.runes, TokenType.dec)],
          parser),
      'STATEMENT(OPECODE(ADDA),OPERAND(GR(GR0),DEC(0)))'
    ],
  ];

  for (final test in tests) {
    final node = test[0] as Node;
    final expected = test[1] as String;
    expect('$node', equals(expected));
  }
}

void testMacroNodeToString() {
  final tests = [
    [
      MacroNode(null, null, Token('IN'.runes, TokenType.opecode), [], parser),
      'MACRO(OPECODE(IN))'
    ],
    [
      MacroNode(null, Token('FOO'.runes, TokenType.label),
          Token('IN'.runes, TokenType.opecode), [], parser),
      'MACRO(LABEL(FOO),OPECODE(IN))'
    ],
    [
      MacroNode(
          null,
          null,
          Token('IN'.runes, TokenType.opecode),
          [
            Token('IBUF'.runes, TokenType.ref),
            Token('LEN'.runes, TokenType.ref),
          ],
          parser),
      'MACRO(OPECODE(IN),OPERAND(REF(IBUF),REF(LEN)))'
    ],
  ];

  for (final test in tests) {
    final node = test[0] as Node;
    final expected = test[1] as String;
    expect('$node', equals(expected));
  }
}

void testSubroutineNodeToString() {
  final tests = [
    [
      SubroutineNode(null, null, [
        StatementNode(
            null,
            null,
            Token('ADDA'.runes, TokenType.opecode),
            [Token('GR0'.runes, TokenType.gr), Token('0'.runes, TokenType.dec)],
            parser),
        StatementNode(
            null, null, Token('RET'.runes, TokenType.opecode), [], parser),
      ]),
      'SUBROUTINE(PROCESS(STATEMENT(OPECODE(ADDA),OPERAND(GR(GR0),DEC(0))),STATEMENT(OPECODE(RET))))'
    ],
    [
      SubroutineNode(Token('FOO'.runes, TokenType.label), null, [
        StatementNode(
            null, null, Token('RET'.runes, TokenType.opecode), [], parser),
      ]),
      'SUBROUTINE(LABEL(FOO),PROCESS(STATEMENT(OPECODE(RET))))'
    ],
    [
      SubroutineNode(null, Token('FOO'.runes, TokenType.ref), [
        StatementNode(
            null,
            null,
            Token('ADDA'.runes, TokenType.opecode),
            [Token('GR0'.runes, TokenType.gr), Token('0'.runes, TokenType.dec)],
            parser),
        StatementNode(null, Token('FOO'.runes, TokenType.label),
            Token('RET'.runes, TokenType.opecode), [], parser),
      ]),
      'SUBROUTINE(START(REF(FOO)),PROCESS(STATEMENT(OPECODE(ADDA),OPERAND(GR(GR0),DEC(0))),STATEMENT(LABEL(FOO),OPECODE(RET))))'
    ],
  ];

  for (final test in tests) {
    final node = test[0] as Node;
    final expected = test[1] as String;
    expect('$node', equals(expected));
  }
}

void testModuleNodeToString() {
  final tests = [
    [
      ModuleNode([
        SubroutineNode(Token('FOO'.runes, TokenType.label), null, [
          StatementNode(
              null, null, Token('RET'.runes, TokenType.opecode), [], parser),
        ]),
        StatementNode(null, null, Token('DC'.runes, TokenType.opecode),
            [Token("'FOO'".runes, TokenType.string)], parser),
      ]),
      "MODULE(SUBROUTINE(LABEL(FOO),PROCESS(STATEMENT(OPECODE(RET)))),STATEMENT(OPECODE(DC),OPERAND(STRING('FOO'))))"
    ],
  ];

  for (final test in tests) {
    final node = test[0] as Node;
    final expected = test[1] as String;
    expect('$node', equals(expected));
  }
}