import 'package:tiamat/src/casl2/lexer/state.dart';
import 'package:test/test.dart';

void main() {
  group('Statement', () {
    test('next()', _testStatementNext);
  });

  group('Text', () {
    test('next()', _testTextNext);
  });
}

void _testStatementNext() {
  final tests = [
    (
      Statement.expectLabel,
      'MAIN    START'.runes.first,
      Statement.label,
    ),
    (
      Statement.expectLabel,
      '        START'.runes.first,
      Statement.expectOpecode,
    ),
    (
      Statement.expectLabel,
      '; COMMENT'.runes.first,
      Statement.comment,
    ),
    (
      Statement.expectLabel,
      ' ; COMMENT'.runes.first,
      Statement.expectOpecode,
    ),
    (
      Statement.expectLabel,
      '0123    START'.runes.first,
      Statement.unexpectedLabel,
    ),
    (
      Statement.label,
      'MAIN    START'.runes.toList()[3],
      Statement.label,
    ),
    (
      Statement.label,
      'MAIN    START'.runes.toList()[4],
      Statement.expectOpecode,
    ),
    (
      Statement.expectOpecode,
      'MAIN    START'.runes.toList()[7],
      Statement.expectOpecode,
    ),
    (
      Statement.expectOpecode,
      'MAIN    START'.runes.toList()[8],
      Statement.opecode,
    ),
    (
      Statement.expectOpecode,
      'MAIN    12345'.runes.toList()[8],
      Statement.unexpectedOpecode,
    ),
    (
      Statement.expectOpecode,
      'MAIN    12345'.runes.toList()[8],
      Statement.unexpectedOpecode,
    ),
    (
      Statement.opecode,
      'MAIN    START'.runes.last,
      Statement.opecode,
    ),
    (
      Statement.opecode,
      'MAIN    START '.runes.last,
      Statement.expectOperand,
    ),
    (
      Statement.opecode,
      'MAIN    START\n'.runes.last,
      Statement.eol,
    ),
    (
      Statement.expectOperand,
      'ADD1    ADD     GR1,GR2'.runes.toList()[15],
      Statement.expectOperand,
    ),
    (
      Statement.expectOperand,
      'ADD1    ADD     GR1,GR2'.runes.toList()[16],
      Statement.ref,
    ),
    (
      Statement.expectOperand,
      'ADD1    DC      1234,GR2'.runes.toList()[16],
      Statement.dec,
    ),
    (
      Statement.expectOperand,
      'ADD1    DC      -1234,GR2'.runes.toList()[16],
      Statement.dec,
    ),
    (
      Statement.expectOperand,
      'ADD1    DC      #1234,GR2'.runes.toList()[16],
      Statement.hex,
    ),
    (
      Statement.expectOperand,
      'ADD1    DC      \'HELLO, WORLD.\''.runes.toList()[16],
      Statement.text,
    ),
    (
      Statement.dec,
      'ADD1    ADD     GR1,1234,GR2'.runes.toList()[23],
      Statement.dec,
    ),
    (
      Statement.dec,
      'ADD1    ADD     GR1,1234,GR2'.runes.toList()[24],
      Statement.separator,
    ),
    (
      Statement.dec,
      'ADD1    ADD     GR1,1234 '.runes.last,
      Statement.expectComment,
    ),
    (
      Statement.dec,
      'ADD1    ADD     GR1,1234\n'.runes.last,
      Statement.eol,
    ),
    (
      Statement.hex,
      'ADD1    ADD     GR1,#1234,GR2'.runes.toList()[24],
      Statement.hex,
    ),
    (
      Statement.hex,
      'ADD1    ADD     GR1,#1234,GR2'.runes.toList()[25],
      Statement.separator,
    ),
    (
      Statement.hex,
      'ADD1    ADD     GR1,#1234 '.runes.last,
      Statement.expectComment,
    ),
    (
      Statement.hex,
      'ADD1    ADD     GR1,#1234\n'.runes.last,
      Statement.eol,
    ),
    (
      Statement.text,
      'ADD1    DC      \'HELLO, WORLD.\',-1'.runes.toList()[30],
      Statement.text,
    ),
    (
      Statement.text,
      'ADD1    DC      \'HELLO, WORLD.\',-1'.runes.toList()[31],
      Statement.separator,
    ),
    (
      Statement.text,
      'ADD1    DC      \'HELLO, WORLD.\' '.runes.last,
      Statement.expectComment,
    ),
    (
      Statement.text,
      'ADD1    DC      \'HELLO, WORLD.\'\n'.runes.last,
      Statement.eol,
    ),
    (
      Statement.ref,
      'ADD1    ADD     GR1,ADDR,GR2'.runes.toList()[23],
      Statement.ref,
    ),
    (
      Statement.ref,
      'ADD1    ADD     GR1,ADDR,GR2'.runes.toList()[24],
      Statement.separator,
    ),
    (
      Statement.ref,
      'ADD1    ADD     GR1,ADDR '.runes.last,
      Statement.expectComment,
    ),
    (
      Statement.ref,
      'ADD1    ADD     GR1,ADDR\n'.runes.last,
      Statement.eol,
    ),
    (
      Statement.expectComment,
      'ADD1    ADD     GR1,ADDR    ; Comment'.runes.toList()[27],
      Statement.expectComment,
    ),
    (
      Statement.expectComment,
      'ADD1    ADD     GR1,ADDR    ; Comment'.runes.toList()[28],
      Statement.comment,
    ),
    (
      Statement.expectComment,
      'ADD1    ADD     GR1,ADDR    Comment'.runes.toList()[28],
      Statement.comment,
    ),
    (
      Statement.comment,
      '; COMMENT'.runes.last,
      Statement.comment,
    ),
    (
      Statement.comment,
      '; COMMENT\n'.runes.last,
      Statement.eol,
    ),
  ];

  var i = 0;
  for (final (stmt, input, expected) in tests) {
    expect(stmt.next(input), equals(expected), reason: 'tests[$i]');
    i += 1;
  }
}

void _testTextNext() {
  final tests = [
    (
      Text.firstQuote,
      '\'HELLO, WORLD.\''.runes.toList()[1],
      Text.rune,
    ),
    (
      Text.rune,
      '\'HELLO, WORLD.\''.runes.last,
      Text.expectEscape,
    ),
    (
      Text.expectEscape,
      '\'HELLO, WORLD.\' '.runes.last,
      Text.end,
    ),
    (
      Text.rune,
      '\'HELLO, WORLD.\n'.runes.last,
      Text.invalid,
    ),
    (
      Text.rune,
      '\'IT\'\'S A SMALL WORLD\''.runes.toList()[3],
      Text.expectEscape,
    ),
    (
      Text.expectEscape,
      '\'IT\'\'S A SMALL WORLD\''.runes.toList()[4],
      Text.escapeRune,
    ),
    (
      Text.escapeRune,
      '\'IT\'\'S A SMALL WORLD\''.runes.toList()[5],
      Text.rune,
    ),
  ];

  var i = 0;
  for (final (stmt, input, expected) in tests) {
    expect(stmt.next(input), equals(expected), reason: 'tests[$i]');
    i += 1;
  }
}
