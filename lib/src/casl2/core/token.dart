/// Type of Token
enum Type {
  comment,
  label,
  opecode,
  operand,
  endLine,
}

/// Token
class Token {
  final int rune;
  final Type type;

  const Token(this.rune, this.type);
}
