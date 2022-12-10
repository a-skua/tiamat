import 'package:tiamat/src/casl2/token/token.dart';
import 'package:tiamat/src/casl2/typedef.dart';
import 'package:tiamat/src/casl2/ast/ast.dart';
import 'package:test/test.dart';

void main() {
  group('Code', () {
    test('value', testCodeValue);
  });

  group('Statement', () {
    test('label', testStatementLabel);
    test('code', testStatementCode);
    test('size', testStatementSize);
    test('position', testStatementPosition);
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

void testStatementLabel() {
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

void testStatementCode() {
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

void testStatementSize() {
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

void testStatementPosition() {
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
