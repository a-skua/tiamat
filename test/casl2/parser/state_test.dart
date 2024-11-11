import 'package:tiamat/src/casl2/token/token.dart';
import 'package:tiamat/src/casl2/ast/ast.dart';
import 'package:tiamat/src/casl2/parser/state.dart';
import 'package:tiamat/src/casl2/typedef.dart';
import 'package:test/test.dart';

void main() {
  group('State', () {
    test('get/set label', testStateGetLabel);
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

void testStateGetLabel() {
  expect(State().getLabel('FOO'), equals(null));

  {
    final stmt = StatementNode(
      Token('START'.runes, TokenType.opecode),
      label: Token('FOO'.runes, TokenType.label),
      operand: [Token('1'.runes, TokenType.dec)],
    );
    expect((State()..setLabel(stmt)).getLabel('FOO'), equals(stmt));
  }

  {
    final stmt1 = StatementNode(
      Token('FOO'.runes, TokenType.label),
      label: Token('START'.runes, TokenType.opecode),
      operand: [Token('1'.runes, TokenType.dec)],
    );

    final stmt2 = StatementNode(
      Token('BAR'.runes, TokenType.label),
      label: Token('START'.runes, TokenType.opecode),
      operand: [Token('1'.runes, TokenType.dec)],
    );

    final parent = State()..setLabel(stmt1);
    final child = State.block(parent)..setLabel(stmt2);

    expect(parent.getLabel('FOO'), equals(stmt1));
    expect(parent.getLabel('BAR'), equals(null));
    expect(child.getLabel('FOO'), equals(stmt1));
    expect(child.getLabel('BAR'), equals(stmt2));
  }
}