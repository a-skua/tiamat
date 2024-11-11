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
      StatementNode(Token('START'.runes, TokenType.opecode),
              label: Token('FOO'.runes, TokenType.label))
          .label,
      equals('FOO'));
  expect(StatementNode(Token('START'.runes, TokenType.opecode)).label,
      equals(null));
}

void testStatementNodeCode() {
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
      // TODO
      StatementNode(opecode, label: label, operand: operand),
      equals(code));
}

void testStatementNodeSize() {
  final label = Token('FOO'.runes, TokenType.label);
  final opecode = Token('START'.runes, TokenType.opecode);
  final operand = [
    Token('1'.runes, TokenType.dec),
  ];

  expect(
      // TODO
      StatementNode(opecode, label: label, operand: operand),
      equals(0));

  expect(
      // TODO
      StatementNode(opecode, label: label, operand: operand),
      equals(0));

  expect(
      // TODO
      StatementNode(opecode, label: label, operand: operand),
      equals(3));
}

void testStatementNodePosition() {
  final label = Token('FOO'.runes, TokenType.label);
  final opecode = Token('START'.runes, TokenType.opecode);
  final operand = [
    Token('1'.runes, TokenType.dec),
  ];

  expect(
      // TODO
      StatementNode(opecode, label: label, operand: operand),
      equals(0));

  expect(
      // TODO
      StatementNode(opecode, label: label, operand: operand),
      equals(6));
}

void testStatementNodeToString() {
  final tests = [
    [
      StatementNode(Token('RET'.runes, TokenType.opecode)),
      'STATEMENT(OPECODE(RET))'
    ],
    [
      StatementNode(
        Token('RET'.runes, TokenType.opecode),
        label: Token('FOO'.runes, TokenType.label),
      ),
      'STATEMENT(LABEL(FOO),OPECODE(RET))'
    ],
    [
      StatementNode(
        Token('ADDA'.runes, TokenType.opecode),
        operand: [
          Token('GR0'.runes, TokenType.gr),
          Token('0'.runes, TokenType.dec)
        ],
      ),
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
    [MacroNode(Token('IN'.runes, TokenType.opecode)), 'MACRO(OPECODE(IN))'],
    [
      MacroNode(Token('IN'.runes, TokenType.opecode),
          label: Token('FOO'.runes, TokenType.label)),
      'MACRO(LABEL(FOO),OPECODE(IN))'
    ],
    [
      MacroNode(
        Token('IN'.runes, TokenType.opecode),
        operand: [
          Token('IBUF'.runes, TokenType.ref),
          Token('LEN'.runes, TokenType.ref),
        ],
      ),
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
      SubroutineNode(StatementNode(Token('START'.runes, TokenType.opecode)), [
        StatementNode(
          Token('ADDA'.runes, TokenType.opecode),
          operand: [
            Token('GR0'.runes, TokenType.gr),
            Token('0'.runes, TokenType.dec)
          ],
        ),
        StatementNode(Token('RET'.runes, TokenType.opecode)),
      ]),
      'SUBROUTINE(PROCESS(STATEMENT(OPECODE(ADDA),OPERAND(GR(GR0),DEC(0))),STATEMENT(OPECODE(RET))))'
    ],
    [
      SubroutineNode(
          StatementNode(Token('START'.runes, TokenType.opecode),
              label: Token('FOO'.runes, TokenType.label)),
          [
            StatementNode(Token('RET'.runes, TokenType.opecode)),
          ]),
      'SUBROUTINE(LABEL(FOO),PROCESS(STATEMENT(OPECODE(RET))))'
    ],
    [
      SubroutineNode(
          StatementNode(Token('START'.runes, TokenType.opecode),
              operand: [Token('FOO'.runes, TokenType.ref)]),
          [
            StatementNode(Token('ADDA'.runes, TokenType.opecode), operand: [
              Token('GR0'.runes, TokenType.gr),
              Token('0'.runes, TokenType.dec)
            ]),
            StatementNode(Token('RET'.runes, TokenType.opecode),
                label: Token('FOO'.runes, TokenType.label)),
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
        SubroutineNode(
            StatementNode(Token('START'.runes, TokenType.opecode),
                label: Token('FOO'.runes, TokenType.label)),
            [
              StatementNode(Token('RET'.runes, TokenType.opecode)),
            ]),
        StatementNode(Token('DC'.runes, TokenType.opecode),
            operand: [Token("'FOO'".runes, TokenType.string)]),
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