typedef Char = int;

/// Type of [Token]
enum TokenType {
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

extension ToString on TokenType {
  /// Convert [TokenType] to [String].
  String get string => switch (this) {
        TokenType.comment => 'COMMENT',
        TokenType.label => 'LABEL',
        TokenType.op => 'OPECODE',
        TokenType.ref => 'REF',
        TokenType.gr => 'GR',
        TokenType.dec => 'DEC',
        TokenType.hex => 'HEX',
        TokenType.text => 'TEXT',
        TokenType.eol => 'EOL',
        TokenType.eof => 'EOF',
        TokenType.separation => 'SEPARATION',
        TokenType.space => 'SPACE',
        TokenType.unexpected => 'UNEXPECTED',
      };
}

/// Token
final class Token {
  final Iterable<Char> runes;

  String get string => String.fromCharCodes(runes);

  final TokenType type;

  /// tokens [start] position.
  final int start;

  /// tokens [end] position.
  final int end;

  /// tokens [lineStart] position.
  final int lineStart;

  /// tokens [lineNumber].
  final int lineNumber;

  const Token(
    this.runes,
    this.type, {
    this.start = 0,
    this.end = 0,
    this.lineStart = 0,
    this.lineNumber = 1,
  });

  factory Token.comment(
    Iterable<Char> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token(runes, TokenType.comment,
          start: start, end: end, lineStart: lineStart, lineNumber: lineNumber);

  factory Token.label(
    Iterable<Char> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token(runes, TokenType.label,
          start: start, end: end, lineStart: lineStart, lineNumber: lineNumber);

  factory Token.op(
    Iterable<Char> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token(runes, TokenType.op,
          start: start, end: end, lineStart: lineStart, lineNumber: lineNumber);

  factory Token.ref(
    Iterable<Char> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token(runes, TokenType.ref,
          start: start, end: end, lineStart: lineStart, lineNumber: lineNumber);

  factory Token.gr(
    final Iterable<Char> runes, {
    final int start = 0,
    final int end = 0,
    final int lineStart = 0,
    final int lineNumber = 1,
  }) =>
      Token(runes, TokenType.gr,
          start: start, end: end, lineStart: lineStart, lineNumber: lineNumber);

  factory Token.dec(
    Iterable<Char> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token(runes, TokenType.dec,
          start: start, end: end, lineStart: lineStart, lineNumber: lineNumber);

  factory Token.hex(
    Iterable<Char> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token(runes, TokenType.hex,
          start: start, end: end, lineStart: lineStart, lineNumber: lineNumber);

  factory Token.text(
    Iterable<Char> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token(runes, TokenType.text,
          start: start, end: end, lineStart: lineStart, lineNumber: lineNumber);

  factory Token.eol(
    Iterable<Char> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token(runes, TokenType.eol,
          start: start, end: end, lineStart: lineStart, lineNumber: lineNumber);

  factory Token.eof(
    Iterable<Char> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token(runes, TokenType.eof,
          start: start, end: end, lineStart: lineStart, lineNumber: lineNumber);

  factory Token.separation(
    Iterable<Char> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token(runes, TokenType.separation,
          start: start, end: end, lineStart: lineStart, lineNumber: lineNumber);

  factory Token.space(
    Iterable<Char> runes, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) =>
      Token(runes, TokenType.space,
          start: start, end: end, lineStart: lineStart, lineNumber: lineNumber);

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

  @override
  String toString() {
    return '${type.string}($string)';
  }
}
