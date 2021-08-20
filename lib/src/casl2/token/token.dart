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
  eol,
  eof,
  error,
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
  }
}

/// Token
class Token {
  final Iterable<int> _runes;
  final TokenType type;
  final int start;
  final int end;
  final int line;
  final int lineStart;
  final int lineEnd;

  const Token(
    this._runes,
    this.type, {
    this.start = 0,
    this.end = 0,
    this.line = 0,
    this.lineStart = 0,
    this.lineEnd = 0,
  });

  List<int> get runes => List.from(_runes);

  String get runesAsString => String.fromCharCodes(_runes);

  String get typeAsString => tokenTypeAsString(type);

  @override
  String toString() {
    return '$typeAsString($runesAsString)';
  }
}

class ErrorToken extends Token {
  final String error;
  ErrorToken(
    Iterable<int> runes,
    this.error, {
    int start = 0,
    int end = 0,
    int line = 0,
    int lineStart = 0,
    int lineEnd = 0,
  }) : super(
          runes,
          TokenType.error,
          start: start,
          end: end,
          line: line,
          lineStart: lineStart,
          lineEnd: lineEnd,
        );
}
