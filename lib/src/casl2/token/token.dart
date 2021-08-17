/// Type of Token
enum TokenType {
  comment,
  label,
  opecode,
  operand,
  eol, // end of line
  eof,
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

  @override
  String toString() {
    return '{type: $type, str: ${String.fromCharCodes(_runes)}}';
  }
}
