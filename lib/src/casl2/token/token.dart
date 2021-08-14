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
  final int startPosition;
  final int endPosition;
  final int lineNumber;
  final int lineStartPosition;
  final int lineEndPosition;

  const Token(
    this._runes,
    this.type, {
    this.startPosition = 0,
    this.endPosition = 0,
    this.lineNumber = 0,
    this.lineStartPosition = 0,
    this.lineEndPosition = 0,
  });

  List<int> get runes => List.from(_runes);

  String get runesAsString => String.fromCharCodes(_runes);

  @override
  String toString() {
    return '{type: $type, str: ${String.fromCharCodes(_runes)}}';
  }
}
