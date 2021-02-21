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
}
