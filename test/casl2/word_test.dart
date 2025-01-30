import 'package:tiamat/casl2.dart';
import 'package:tiamat/src/typedef/typedef.dart';
import 'package:test/test.dart';

void main() {
  group('Constant', () {
    test('real()', testConstantReal);
    test('get labels', testConstantLabels);
  });

  group('Reference', () {
    test('real()', testReferenceReal);
    test('get labels', testReferenceLabels);
  });

  group('Words', () {
    test('get words', testWordsWords);
    test('get label', testWordsLabel);
  });
}

void testConstantReal() {
  final tests = [
    (Constant(1, []), (_) => null, Ok(1)),
    (Constant(2, []), (_) => null, Ok(2)),
  ];

  for (final (word, resolve, expected) in tests) {
    expect(word.real(resolve), equals(expected));
  }
}

void testConstantLabels() {
  final tests = [
    (Constant(1, []), []),
    (Constant(2, ['FOO']), ['FOO']),
  ];

  for (final (word, expected) in tests) {
    expect(word.labels, equals(expected));
  }
}

void testReferenceReal() {
  final tests = [
    (
      Reference(Token.ref('FOO'.runes), []),
      (_) => 1,
      Ok(1),
    ),
    (
      Reference(Token.ref('FOO'.runes), []),
      (_) => null,
      Err(CompileError.fromToken(
        '[ERROR] UNKNOWN LABEL=FOO',
        Token.ref('FOO'.runes),
      )),
    ),
  ];

  for (final (word, resolve, expected) in tests) {
    expect(word.real(resolve), equals(expected));
  }
}

void testReferenceLabels() {
  final tests = [
    (Reference(Token.ref('FOO'.runes), []), []),
    (Reference(Token.ref('FOO'.runes), ['BAR']), ['BAR']),
  ];

  for (final (word, expected) in tests) {
    expect(word.labels, equals(expected));
  }
}

void testWordsWords() {
  final tests = [
    (
      Words(null, [Constant(1, []), Constant(2, [])]),
      '[CONST(1), CONST(2)]',
    ),
  ];

  for (final (block, expected) in tests) {
    expect('${block.words}', equals(expected));
  }
}

void testWordsLabel() {
  final tests = [
    (
      Words(null, []),
      'null',
    ),
    (
      Words('FOO', [
        Constant(1, ['FOO']),
        Constant(2, ['BAR']),
      ]),
      '(FOO, CONST(1))',
    ),
  ];

  for (final (block, expected) in tests) {
    expect('${block.label}', equals(expected));
  }
}
