import 'package:tiamat/src/casl2/lexer/token.dart';
import 'package:tiamat/src/casl2/parser/ast.dart';
import 'package:tiamat/src/casl2/compiler/compiler.dart';
import 'package:tiamat/src/typedef/typedef.dart';
import 'package:test/test.dart';

void main() {
  group('Code', () {
    test('value', testCodeValue);
  });

  group('TODO', () {
    test('code', testStatementNodeCode);
    test('size', testStatementNodeSize);
    test('position', testStatementNodePosition);
  });
}

void testCodeValue() {
  expect(Code((base) => base + 50).value(), equals(50));
  expect(Code((base) => base + 50).value(100), equals(150));
}

void testStatementNodeCode() {
  final label = Token.label('FOO'.runes);
  final opecode = Token.op('START'.runes);
  final operand = [Token.dec('1'.runes)];

  final code = Ok([
    Code((_) => 1),
    Code((_) => 2),
    Code((_) => 3),
  ]);

  expect(
    Statement(opecode, label: label, operand: operand),
    equals(code),
    reason: 'TODO',
  );
}

void testStatementNodeSize() {
  final label = Token.label('FOO'.runes);
  final opecode = Token.op('START'.runes);
  final operand = [Token.dec('1'.runes)];

  expect(
    Statement(opecode, label: label, operand: operand),
    equals(0),
    reason: 'TODO',
  );

  expect(
    Statement(opecode, label: label, operand: operand),
    equals(0),
    reason: 'TODO',
  );

  expect(
    Statement(opecode, label: label, operand: operand),
    equals(3),
    reason: 'TODO',
  );
}

void testStatementNodePosition() {
  final label = Token.label('FOO'.runes);
  final opecode = Token.op('START'.runes);
  final operand = [Token.dec('1'.runes)];

  expect(
    Statement(opecode, label: label, operand: operand),
    equals(0),
    reason: 'TODO',
  );

  expect(
    Statement(opecode, label: label, operand: operand),
    equals(6),
    reason: 'TODO',
  );
}
