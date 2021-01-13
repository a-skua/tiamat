enum _State {
  comment,
  label,
  endLabel,
  instruction,
  endInstruction,
  operand,
  string,
  metaChar,
  endOperand,
}

enum State {
  comment,
  label,
  instruction,
  operand,
  newline,
}

class Token {
  final int rune;
  final State state;

  Token(this.rune, this.state);
}

List<Token> parse(String s) {
  final tokens = <Token>[];
  var state = _State.label;

  final tab = '\t'.runes.first;
  final newline = '\n'.runes.first;
  final space = ' '.runes.first;
  final semicolon = ';'.runes.first;
  final quote = '\''.runes.first;
  final backslash = '\\'.runes.first;

  for (final c in s.runes) {
    switch (state) {
      case _State.comment:
        if (c == newline) {
          state = _State.label;
          tokens.add(Token(c, State.newline));
          break;
        }
        tokens.add(Token(c, State.comment));
        break;
      case _State.label:
        if (c == tab || c == space) {
          state = _State.endLabel;
          break;
        }
        if (c == newline) {
          tokens.add(Token(c, State.newline));
          break;
        }
        if (c == semicolon) {
          state = _State.comment;
          tokens.add(Token(c, State.comment));
          break;
        }
        tokens.add(Token(c, State.label));
        break;
      case _State.endLabel:
        if (c == semicolon) {
          state = _State.comment;
          tokens.add(Token(c, State.comment));
          break;
        }
        if (c != tab && c != space) {
          state = _State.instruction;
          tokens.add(Token(c, State.instruction));
          break;
        }
        break;
      case _State.instruction:
        if (c == newline) {
          state = _State.label;
          tokens.add(Token(c, State.newline));
          break;
        }
        if (c == tab || c == space) {
          state = _State.endInstruction;
          break;
        }
        tokens.add(Token(c, State.instruction));
        break;
      case _State.endInstruction:
        if (c == newline) {
          state = _State.label;
          tokens.add(Token(c, State.newline));
          break;
        }
        if (c == semicolon) {
          state = _State.comment;
          tokens.add(Token(c, State.comment));
          break;
        }
        if (c == quote) {
          state = _State.string;
          tokens.add(Token(c, State.operand));
          break;
        }
        if (c != tab && c != space) {
          state = _State.operand;
          tokens.add(Token(c, State.operand));
          break;
        }
        break;
      case _State.operand:
        if (c == newline) {
          state = _State.label;
          tokens.add(Token(c, State.newline));
          break;
        }
        if (c == quote) {
          state = _State.string;
          tokens.add(Token(c, State.operand));
          break;
        }
        if (c == tab || c == space) {
          state = _State.endOperand;
          break;
        }
        tokens.add(Token(c, State.operand));
        break;
      case _State.endOperand:
        if (c == newline) {
          state = _State.label;
          tokens.add(Token(c, State.newline));
          break;
        }
        if (c != tab && c != space) {
          state = _State.comment;
          tokens.add(Token(c, State.comment));
          break;
        }
        break;
      case _State.string:
        if (c == quote) {
          state = _State.metaChar;
          tokens.add(Token(c, State.operand));
          break;
        }
        tokens.add(Token(c, State.operand));
        break;
      case _State.metaChar:
        if (c == quote) {
          state = _State.string;
          tokens.add(Token(c, State.operand));
          break;
        }
        if (c == tab || c == space) {
          state = _State.endOperand;
          break;
        }
        state = _State.operand;
        tokens.add(Token(c, State.operand));
        break;
    }
  }
  return tokens;
}
