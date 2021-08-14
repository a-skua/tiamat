/// Type of Token
enum TokenType {
  comment,
  label,
  opecode,
  operand,
  endOfLine,
}

/// Token
class Token {
  final List<int> runes;
  final TokenType type;
  final int startPosition;
  final int endPosition;
  final int lineNumber;
  final int lineStartPosition;
  final int lineEndPosition;

  const Token(
    this.rune,
    this.type, {
    this.startPosition,
    this.endPosition,
    this.lineNumber,
    this.lineStartPosition,
    this.lineEndPosition,
  });

  String toString() {
    return '{type: $type, str: ${String.fromCharCodes(runes)}}';
  }
}
