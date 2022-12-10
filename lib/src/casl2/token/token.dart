/// Type of Token
enum TokenType {
  comment,
  label,
  opecode,
  ident, // LABEL
  gr, //  GR0 ~ GR7
  dec, // -32768 ~ 32767
  hex, // #0000 ~ FFFF
  string, // 'STRING'
  // End of Line
  eol,
  // End of File
  eof,
  error,
  separation, // ','
  space, // '\t' or ' '
}

String tokenTypeAsString(TokenType type) {
  switch (type) {
    case TokenType.comment:
      return 'COMMENT';
    case TokenType.label:
      return 'LABEL';
    case TokenType.opecode:
      return 'OPECODE';
    case TokenType.ident:
      return 'IDENT';
    case TokenType.gr:
      return 'GR';
    case TokenType.dec:
      return 'DEC';
    case TokenType.hex:
      return 'HEX';
    case TokenType.string:
      return 'STRING';
    case TokenType.eol:
      return 'EOL';
    case TokenType.eof:
      return 'EOF';
    case TokenType.error:
      return 'ERROR';
    case TokenType.separation:
      return 'SEPARATION';
    case TokenType.space:
      return 'SPACE';
  }
}

/// Token
class Token {
  final Iterable<int> _runes;
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
    this._runes,
    this.type, {
    this.start = 0,
    this.end = 0,
    this.lineStart = 0,
    this.lineNumber = 1,
  });

  List<int> get runes => List.from(_runes);

  String get runesAsString => String.fromCharCodes(_runes);

  String get typeAsString => tokenTypeAsString(type);

  @override
  String toString() {
    return '$typeAsString($runesAsString)';
  }
}

/// error
class ErrorToken extends Token {
  final String error;
  ErrorToken(
    Iterable<int> runes,
    this.error, {
    int start = 0,
    int end = 0,
    int lineStart = 0,
    int lineNumber = 1,
  }) : super(
          runes,
          TokenType.error,
          start: start,
          end: end,
          lineStart: lineStart,
          lineNumber: lineNumber,
        );
}
