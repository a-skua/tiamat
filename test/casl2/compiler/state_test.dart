import 'package:tiamat/src/casl2/lexer/token.dart';
import 'package:tiamat/src/casl2/parser/ast.dart';
import 'package:tiamat/src/casl2/compiler/state.dart';
import 'package:test/test.dart';

void main() {
  group('State', () {
    test('get/set label', testStateGetLabel);
  });
}

void testStateGetLabel() {
  expect(State().getLabel('FOO'), equals(null));

  {
    final stmt = Statement(
      Token.op('START'.runes),
      label: Token.label('FOO'.runes),
      operand: [Token.dec('1'.runes)],
    );
    expect((State()..setLabel(stmt)).getLabel('FOO'), equals(stmt));
  }

  {
    final stmt1 = Statement(
      Token.op('START'.runes),
      label: Token.label('FOO'.runes),
      operand: [Token.dec('1'.runes)],
    );

    final stmt2 = Statement(
      Token.op('START'.runes),
      label: Token.label('BAR'.runes),
      operand: [Token.dec('1'.runes)],
    );

    final parent = State()..setLabel(stmt1);
    final child = State.block(parent)..setLabel(stmt2);

    expect(parent.getLabel('FOO'), equals(stmt1));
    expect(parent.getLabel('BAR'), equals(null));
    expect(child.getLabel('FOO'), equals(stmt1));
    expect(child.getLabel('BAR'), equals(stmt2));
  }
}
