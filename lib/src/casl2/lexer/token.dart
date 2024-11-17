import '../word.dart' show Rune;

/// Type of [Token]
enum Type {
  /// '; COMMENT'
  comment,

  /// 'LABEL'
  label,

  /// 'OPECODE'
  op,

  /// 'REF'
  ref,

  ///  GR0 ~ GR7
  gr,

  /// -32768 ~ 32767
  dec,

  /// #0000 ~ FFFF
  hex,

  /// 'TEXT'
  text,

  /// End of Line
  eol,

  /// End of File
  eof,

  /// ','
  separation,

  /// '\t' or ' '
  space,

  /// Unexpected Token
  unexpected,
}

extension ToString on Type {
  /// Convert [Type] to [String].
  String get string => switch (this) {
        Type.comment => 'COMMENT',
        Type.label => 'LABEL',
        Type.op => 'OPECODE',
        Type.ref => 'REF',
        Type.gr => 'GR',
        Type.dec => 'DEC',
        Type.hex => 'HEX',
        Type.text => 'TEXT',
        Type.eol => 'EOL',
        Type.eof => 'EOF',
        Type.separation => 'SEPARATION',
        Type.space => 'SPACE',
        Type.unexpected => 'UNEXPECTED',
      };
}

/// Token
final class Token {
  final Iterable<Rune> runes;

  String get string => String.fromCharCodes(runes);

  final Type type;

  /// tokens [start] position.
  final int start;

  /// tokens [end] position.
  final int end;

  /// tokens [lineStart] position.
  final int lineStart;

  /// tokens [lineNumber].
  final int lineNumber;

  const Token._(this.runes, this.type, this.start, this.end, this.lineStart,
      this.lineNumber);

  bool get isComment => type == Type.comment;
  bool get isNotComment => !isComment;
  bool get isLabel => type == Type.label;
  bool get isNotLabel => !isLabel;
  bool get isOp => type == Type.op;
  bool get isNotOp => !isOp;
  bool get isRef => type == Type.ref;
  bool get isNotRef => !isRef;
  bool get isGr => type == Type.gr;
  bool get isNotGr => !isGr;
  bool get isDec => type == Type.dec;
  bool get isNotDec => !isDec;
  bool get isHex => type == Type.hex;
  bool get isNotHex => !isHex;
  bool get isText => type == Type.text;
  bool get isNotText => !isText;
  bool get isEol => type == Type.eol;
  bool get isNotEol => !isEol;
  bool get isEof => type == Type.eof;
  bool get isNotEof => !isEof;
  bool get isSeparation => type == Type.separation;
  bool get isNotSeparation => !isSeparation;
  bool get isSpace => type == Type.space;
  bool get isNotSpace => !isSpace;
  bool get isUnexpected => type == Type.unexpected;
  bool get isNotUnexpected => !isUnexpected;

  @override
  String toString() {
    return '${type.string}($string)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Token &&
        other.type == type &&
        other.start == start &&
        other.end == end &&
        other.lineStart == lineStart &&
        other.lineNumber == lineNumber &&
        other.string == string;
  }

  factory Token(
    Iterable<Rune> runes,
    Type type, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token._(runes, type, start, end, lineStart, lineNumber);

  factory Token.comment(
    Iterable<Rune> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token._(runes, Type.comment, start, end, lineStart, lineNumber);

  factory Token.label(
    Iterable<Rune> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token._(runes, Type.label, start, end, lineStart, lineNumber);

  factory Token.op(
    Iterable<Rune> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token._(runes, Type.op, start, end, lineStart, lineNumber);

  factory Token.ref(
    Iterable<Rune> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token._(runes, Type.ref, start, end, lineStart, lineNumber);

  factory Token.gr(
    final Iterable<Rune> runes, {
    final int start = 0,
    final int end = 0,
    final int lineStart = 0,
    final int lineNumber = 1,
  }) =>
      Token._(runes, Type.gr, start, end, lineStart, lineNumber);

  factory Token.dec(
    Iterable<Rune> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token._(runes, Type.dec, start, end, lineStart, lineNumber);

  factory Token.hex(
    Iterable<Rune> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token._(runes, Type.hex, start, end, lineStart, lineNumber);

  factory Token.text(
    Iterable<Rune> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token._(runes, Type.text, start, end, lineStart, lineNumber);

  factory Token.eol(
    Iterable<Rune> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token._(runes, Type.eol, start, end, lineStart, lineNumber);

  factory Token.eof(
    Iterable<Rune> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token._(runes, Type.eof, start, end, lineStart, lineNumber);

  factory Token.separation(
    Iterable<Rune> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token._(runes, Type.separation, start, end, lineStart, lineNumber);

  factory Token.space(
    Iterable<Rune> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token._(runes, Type.space, start, end, lineStart, lineNumber);

  factory Token.unexpected(
    Iterable<Rune> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token._(runes, Type.unexpected, start, end, lineStart, lineNumber);
}
