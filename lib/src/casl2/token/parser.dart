import 'token.dart';

enum State {
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

List<Token> parse(String s) {
  final tokens = <Token>[];
  var state = State.label;

  final tab = '\t'.runes.first;
  final newline = '\n'.runes.first;
  final space = ' '.runes.first;
  final semicolon = ';'.runes.first;
  final quote = '\''.runes.first;
  final backslash = '\\'.runes.first;

  for (final c in s.runes) {
    switch (state) {
      case State.comment:
        if (c == newline) {
          // |; comment\n
          // |`````````^
          state = State.label;
          tokens.add(Token(c, Type.endLine));
          break;
        }
        tokens.add(Token(c, Type.comment));
        break;
      case State.label:
        if (c == tab || c == space) {
          // |LABEL   NOP
          // |`````^
          // +
          // |        NOP
          // |^
          state = State.endLabel;
          break;
        }
        if (c == newline) {
          // NOTE: wrong format.
          // |LABEL\n
          // |`````^
          tokens.add(Token(c, Type.endLine));
          break;
        }
        if (c == semicolon) {
          // NOTE: wrong format.
          // |LABEL; comment
          // |`````^
          state = State.comment;
          tokens.add(Token(c, Type.comment));
          break;
        }
        tokens.add(Token(c, Type.label));
        break;
      case State.endLabel:
        if (c == semicolon) {
          // |  ; comment
          // |``^
          // +
          // |; comment
          // |^
          // +
          // NOTE: wrong format.
          // |LABEL   ; comment
          // |````````^
          state = State.comment;
          tokens.add(Token(c, Type.comment));
          break;
        }
        if (c != tab && c != space) {
          // |LABEL   NOP
          // |````````^
          state = State.instruction;
          tokens.add(Token(c, Type.instruction));
          break;
        }
        break;
      case State.instruction:
        if (c == newline) {
          // |LABEL   NOP\n
          // |```````````^
          state = State.label;
          tokens.add(Token(c, Type.endLine));
          break;
        }
        if (c == semicolon) {
          // NOTE: wrong format.
          // |LABEL   NOP; comment
          // |```````````^
          state = State.comment;
          tokens.add(Token(c, Type.comment));
        }
        if (c == tab || c == space) {
          // |LABEL   ADDA    GR0,GR1
          // |````````````^
          state = State.endInstruction;
          break;
        }
        tokens.add(Token(c, Type.instruction));
        break;
      case State.endInstruction:
        if (c == newline) {
          // |LABEL   NOP     \n
          // |````````````````^
          state = State.label;
          tokens.add(Token(c, Type.endLine));
          break;
        }
        if (c == semicolon) {
          // |LABEL   NOP     ; comment
          // |````````````````^
          state = State.comment;
          tokens.add(Token(c, Type.comment));
          break;
        }
        if (c == quote) {
          // |LABEL   DC      'hello, world'
          // |````````````````^
          state = State.string;
          tokens.add(Token(c, Type.operand));
          break;
        }
        if (c != tab && c != space) {
          // |LABEL   ADDA    GR0,GR1
          // |````````````````^
          state = State.operand;
          tokens.add(Token(c, Type.operand));
          break;
        }
        break;
      case State.operand:
        if (c == newline) {
          // |LABEL   ADDA    GR0,GR1\n
          // |```````````````````````^
          state = State.label;
          tokens.add(Token(c, Type.endLine));
          break;
        }
        if (c == quote) {
          // |LABEL   DC      0,'hello, world'
          // |``````````````````^
          state = State.string;
          tokens.add(Token(c, Type.operand));
          break;
        }
        if (c == tab || c == space) {
          // |LABEL   ADDA    GR0,GR1 ; comment
          // |```````````````````````^
          state = State.endOperand;
          break;
        }
        tokens.add(Token(c, Type.operand));
        break;
      case State.endOperand:
        if (c == newline) {
          // |LABEL   ADDA    GR0,GR1 \n
          // |````````````````````````^
          state = State.label;
          tokens.add(Token(c, Type.endLine));
          break;
        }
        if (c != tab && c != space) {
          // |LABEL   ADDA    GR0,GR1 comment
          // |````````````````````````^
          state = State.comment;
          tokens.add(Token(c, Type.comment));
          break;
        }
        break;
      case State.string:
        if (c == quote) {
          // |LABEL   DC      'hello, world'
          // |`````````````````````````````^
          // +
          // |LABEL   DC      'it''a small world'
          // |```````````````````^
          state = State.metaChar;
          tokens.add(Token(c, Type.operand));
          break;
        }
        tokens.add(Token(c, Type.operand));
        break;
      case State.metaChar:
        if (c == quote) {
          // |LABEL   DC      'it''a small world'
          // |````````````````````^
          state = State.string;
          tokens.add(Token(c, Type.operand));
          break;
        }
        if (c == newline) {
          // |LABEL   DC      'hello, world'\n
          // |``````````````````````````````^
          state = State.label;
          tokens.add(Token(c, Type.endLine));
          break;
        }
        if (c == tab || c == space) {
          // |LABEL   DC      'hello, world'  comment
          // |``````````````````````````````^
          state = State.endOperand;
          break;
        }
        // |LABEL   DC      'hello, world',-1
        // |``````````````````````````````^
        state = State.operand;
        tokens.add(Token(c, Type.operand));
        break;
    }
  }
  return tokens;
}
