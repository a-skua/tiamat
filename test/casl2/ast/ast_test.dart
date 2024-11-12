import 'package:tiamat/src/casl2/token/token.dart';
import 'package:tiamat/src/casl2/typedef.dart';
import 'package:tiamat/src/casl2/ast/ast.dart';
import 'package:tiamat/src/casl2/parser/parser.dart';
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
      StatementNode(Token.op('START'.runes), label: Token.label('FOO'.runes))
          .label,
      equals('FOO'));
  expect(StatementNode(Token.op('START'.runes)).label, equals(null));
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
      StatementNode(opecode, label: label, operand: operand),
      equals(code));
}

void testStatementNodeSize() {
  final label = Token.label('FOO'.runes);
  final opecode = Token.op('START'.runes);
  final operand = [Token.dec('1'.runes)];

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
  final label = Token.label('FOO'.runes);
  final opecode = Token.op('START'.runes);
  final operand = [Token.dec('1'.runes)];

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
    [StatementNode(Token.op('RET'.runes)), 'STATEMENT(OPECODE(RET))'],
    [
      StatementNode(
        Token.op('RET'.runes),
        label: Token.label('FOO'.runes),
      ),
      'STATEMENT(LABEL(FOO),OPECODE(RET))'
    ],
    [
      StatementNode(
        Token.op('ADDA'.runes),
        operand: [Token.gr('GR0'.runes), Token.dec('0'.runes)],
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
    [MacroNode(Token.op('IN'.runes)), 'MACRO(OPECODE(IN))'],
    [
      MacroNode(Token.op('IN'.runes), label: Token.label('FOO'.runes)),
      'MACRO(LABEL(FOO),OPECODE(IN))'
    ],
    [
      MacroNode(
        Token.op('IN'.runes),
        operand: [Token.ref('IBUF'.runes), Token.ref('LEN'.runes)],
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
      SubroutineNode(StatementNode(Token.op('START'.runes)), [
        StatementNode(
          Token.op('ADDA'.runes),
          operand: [Token.gr('GR0'.runes), Token.dec('0'.runes)],
        ),
        StatementNode(Token.op('RET'.runes)),
      ]),
      'SUBROUTINE(PROCESS(STATEMENT(OPECODE(ADDA),OPERAND(GR(GR0),DEC(0))),STATEMENT(OPECODE(RET))))'
    ],
    [
      SubroutineNode(
          StatementNode(Token.op('START'.runes),
              label: Token.label('FOO'.runes)),
          [
            StatementNode(Token.op('RET'.runes)),
          ]),
      'SUBROUTINE(LABEL(FOO),PROCESS(STATEMENT(OPECODE(RET))))'
    ],
    [
      SubroutineNode(
          StatementNode(Token.op('START'.runes),
              operand: [Token.ref('FOO'.runes)]),
          [
            StatementNode(Token.op('ADDA'.runes),
                operand: [Token.gr('GR0'.runes), Token.dec('0'.runes)]),
            StatementNode(Token.op('RET'.runes),
                label: Token.label('FOO'.runes)),
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
            StatementNode(Token.op('START'.runes),
                label: Token.label('FOO'.runes)),
            [StatementNode(Token.op('RET'.runes))]),
        StatementNode(Token.op('DC'.runes),
            operand: [Token.text("'FOO'".runes)]),
      ]),
      "MODULE(SUBROUTINE(LABEL(FOO),PROCESS(STATEMENT(OPECODE(RET)))),STATEMENT(OPECODE(DC),OPERAND(TEXT('FOO'))))"
    ],
  ];

  for (final test in tests) {
    final node = test[0] as Node;
    final expected = test[1] as String;
    expect('$node', equals(expected));
  }
}