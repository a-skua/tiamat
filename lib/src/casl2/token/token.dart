/// Type of Token
enum TokenType {
  comment,
  label,
  opecode,
  ident, // GR0 ~ GR7, LABEL
  dec, // -32768 ~ 32767
  hex, // #0000 ~ FFFF
  string, // 'STRING'
  eol,
  eof,
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
