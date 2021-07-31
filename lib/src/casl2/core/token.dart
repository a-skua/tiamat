/// Type of Token
enum TokenType {
  comment,
  label,
  opecode,
  operand,
  endLine,
}

/// Token
class Token {
  final int rune;
  final TokenType type;

  const Token(this.rune, this.type);

  String toString() {
    return '0x${(this.rune & 0xffff).toRadixString(16).padLeft(4, '0')}';
  }
}
