enum Type {
  comment,
  label,
  instruction,
  operand,
  endLine,
}

class Token {
  final int rune;
  final Type type;

  Token(this.rune, this.type);
}
