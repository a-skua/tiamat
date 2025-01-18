import 'package:tiamat/src/casl2/lexer/token.dart';
import 'package:test/test.dart';

void main() {
  group('Token', () {
    test('isComment', _testTokenIsComment);
    test('isLabel', _testTokenIsLabel);
    test('isOp', _testTokenIsOp);
    test('isRef', _testTokenIsRef);
    test('isGr', _testTokenIsGr);
    test('isDec', _testTokenIsDec);
    test('isHex', _testTokenIsHex);
    test('isText', _testTokenIsText);
    test('isEol', _testTokenIsEol);
    test('isEof', _testTokenIsEof);
    test('isSeparation', _testTokenIsSeparation);
    test('isSpace', _testSpace);
    test('isUnexpected', _testTokenIsUnexpected);
  });
}

void _testTokenIsComment() {
  final tests = [
    (Token.comment('; COMMENT'.runes), true),
    (Token.op('START'.runes), false),
    (Token('; COMMENT'.runes, Type.comment), true),
    (Token('START'.runes, Type.op), false),
  ];

  for (final (token, expected) in tests) {
    expect(token.isComment, equals(expected));
    expect(token.isNotComment, isNot(equals(expected)));
  }
}

void _testTokenIsLabel() {
  final tests = [
    (Token.label('MAIN'.runes), true),
    (Token.op('START'.runes), false),
    (Token('MAIN'.runes, Type.label), true),
    (Token('START'.runes, Type.op), false),
  ];

  for (final (token, expected) in tests) {
    expect(token.isLabel, equals(expected));
    expect(token.isNotLabel, isNot(equals(expected)));
  }
}

void _testTokenIsOp() {
  final tests = [
    (Token.label('MAIN'.runes), false),
    (Token.op('START'.runes), true),
    (Token('MAIN'.runes, Type.label), false),
    (Token('START'.runes, Type.op), true),
  ];

  for (final (token, expected) in tests) {
    expect(token.isOp, equals(expected));
    expect(token.isNotOp, isNot(equals(expected)));
  }
}

void _testTokenIsRef() {
  final tests = [
    (Token.op('START'.runes), false),
    (Token.ref('FOO'.runes), true),
    (Token('START'.runes, Type.op), false),
    (Token('FOO'.runes, Type.ref), true),
  ];

  for (final (token, expected) in tests) {
    expect(token.isRef, equals(expected));
    expect(token.isNotRef, isNot(equals(expected)));
  }
}

void _testTokenIsGr() {
  final tests = [
    (Token.op('ADD'.runes), false),
    (Token.gr('GR0'.runes), true),
    (Token('ADD'.runes, Type.op), false),
    (Token('GR0'.runes, Type.gr), true),
  ];

  for (final (token, expected) in tests) {
    expect(token.isGr, equals(expected));
    expect(token.isNotGr, isNot(equals(expected)));
  }
}

void _testTokenIsDec() {
  final tests = [
    (Token.dec('127'.runes), true),
    (Token.hex('#007F'.runes), false),
    (Token('127'.runes, Type.dec), true),
    (Token('#007F'.runes, Type.hex), false),
  ];

  for (final (token, expected) in tests) {
    expect(token.isDec, equals(expected));
    expect(token.isNotDec, isNot(equals(expected)));
  }
}

void _testTokenIsHex() {
  final tests = [
    (Token.dec('127'.runes), false),
    (Token.hex('#007F'.runes), true),
    (Token('127'.runes, Type.dec), false),
    (Token('#007F'.runes, Type.hex), true),
  ];

  for (final (token, expected) in tests) {
    expect(token.isHex, equals(expected));
    expect(token.isNotHex, isNot(equals(expected)));
  }
}

void _testTokenIsText() {
  final tests = [
    (Token.text("'FOO'".runes), true),
    (Token.dec('127'.runes), false),
    (Token("'FOO'".runes, Type.text), true),
    (Token('127'.runes, Type.dec), false),
  ];

  for (final (token, expected) in tests) {
    expect(token.isText, equals(expected));
    expect(token.isNotText, isNot(equals(expected)));
  }
}

void _testTokenIsEol() {
  final tests = [
    (Token.eol('\n'.runes), true),
    (Token.dec('127'.runes), false),
    (Token('\n'.runes, Type.eol), true),
    (Token('127'.runes, Type.dec), false),
  ];

  for (final (token, expected) in tests) {
    expect(token.isEol, equals(expected));
    expect(token.isNotEol, isNot(equals(expected)));
  }
}

void _testTokenIsEof() {
  final tests = [
    (Token.eof([]), true),
    (Token.dec('127'.runes), false),
    (Token([], Type.eof), true),
    (Token('127'.runes, Type.dec), false),
  ];

  for (final (token, expected) in tests) {
    expect(token.isEof, equals(expected));
    expect(token.isNotEof, isNot(equals(expected)));
  }
}

void _testTokenIsSeparation() {
  final tests = [
    (Token.separation(','.runes), true),
    (Token.dec('127'.runes), false),
    (Token(','.runes, Type.separation), true),
    (Token('127'.runes, Type.dec), false),
  ];

  for (final (token, expected) in tests) {
    expect(token.isSeparation, equals(expected));
    expect(token.isNotSeparation, isNot(equals(expected)));
  }
}

void _testSpace() {
  final tests = [
    (Token.space(' '.runes), true),
    (Token.dec('127'.runes), false),
    (Token(' '.runes, Type.space), true),
    (Token('127'.runes, Type.dec), false),
  ];

  for (final (token, expected) in tests) {
    expect(token.isSpace, equals(expected));
    expect(token.isNotSpace, isNot(equals(expected)));
  }
}

void _testTokenIsUnexpected() {
  final tests = [
    (Token.unexpected('!'.runes), true),
    (Token.dec('127'.runes), false),
    (Token('!'.runes, Type.unexpected), true),
    (Token('127'.runes, Type.dec), false),
  ];

  for (final (token, expected) in tests) {
    expect(token.isUnexpected, equals(expected));
    expect(token.isNotUnexpected, isNot(equals(expected)));
  }
}
