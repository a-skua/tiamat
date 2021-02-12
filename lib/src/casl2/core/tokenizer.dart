import 'token.dart';

enum _State {
  comment,
  label,
  endLabel,
  opecode,
  endOpecode,
  operand,
  string,
  metaChar,
  endOperand,
}

List<Token> tokenize(String s) {
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
          // |; comment\n
          // |`````````^
          state = _State.label;
          tokens.add(Token(c, Type.endLine));
          break;
        }
        tokens.add(Token(c, Type.comment));
        break;
      case _State.label:
        if (c == tab || c == space) {
          // |LABEL   NOP
          // |`````^
          // +
          // |        NOP
          // |^
          state = _State.endLabel;
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
          state = _State.comment;
          tokens.add(Token(c, Type.comment));
          break;
        }
        tokens.add(Token(c, Type.label));
        break;
      case _State.endLabel:
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
          state = _State.comment;
          tokens.add(Token(c, Type.comment));
          break;
        }
        if (c != tab && c != space) {
          // |LABEL   NOP
          // |````````^
          state = _State.opecode;
          tokens.add(Token(c, Type.opecode));
          break;
        }
        break;
      case _State.opecode:
        if (c == newline) {
          // |LABEL   NOP\n
          // |```````````^
          state = _State.label;
          tokens.add(Token(c, Type.endLine));
          break;
        }
        if (c == semicolon) {
          // NOTE: wrong format.
          // |LABEL   NOP; comment
          // |```````````^
          state = _State.comment;
          tokens.add(Token(c, Type.comment));
        }
        if (c == tab || c == space) {
          // |LABEL   ADDA    GR0,GR1
          // |````````````^
          state = _State.endOpecode;
          break;
        }
        tokens.add(Token(c, Type.opecode));
        break;
      case _State.endOpecode:
        if (c == newline) {
          // |LABEL   NOP     \n
          // |````````````````^
          state = _State.label;
          tokens.add(Token(c, Type.endLine));
          break;
        }
        if (c == semicolon) {
          // |LABEL   NOP     ; comment
          // |````````````````^
          state = _State.comment;
          tokens.add(Token(c, Type.comment));
          break;
        }
        if (c == quote) {
          // |LABEL   DC      'hello, world'
          // |````````````````^
          state = _State.string;
          tokens.add(Token(c, Type.operand));
          break;
        }
        if (c != tab && c != space) {
          // |LABEL   ADDA    GR0,GR1
          // |````````````````^
          state = _State.operand;
          tokens.add(Token(c, Type.operand));
          break;
        }
        break;
      case _State.operand:
        if (c == newline) {
          // |LABEL   ADDA    GR0,GR1\n
          // |```````````````````````^
          state = _State.label;
          tokens.add(Token(c, Type.endLine));
          break;
        }
        if (c == quote) {
          // |LABEL   DC      0,'hello, world'
          // |``````````````````^
          state = _State.string;
          tokens.add(Token(c, Type.operand));
          break;
        }
        if (c == tab || c == space) {
          // |LABEL   ADDA    GR0,GR1 ; comment
          // |```````````````````````^
          state = _State.endOperand;
          break;
        }
        tokens.add(Token(c, Type.operand));
        break;
      case _State.endOperand:
        if (c == newline) {
          // |LABEL   ADDA    GR0,GR1 \n
          // |````````````````````````^
          state = _State.label;
          tokens.add(Token(c, Type.endLine));
          break;
        }
        if (c != tab && c != space) {
          // |LABEL   ADDA    GR0,GR1 comment
          // |````````````````````````^
          state = _State.comment;
          tokens.add(Token(c, Type.comment));
          break;
        }
        break;
      case _State.string:
        if (c == quote) {
          // |LABEL   DC      'hello, world'
          // |`````````````````````````````^
          // +
          // |LABEL   DC      'it''a small world'
          // |```````````````````^
          state = _State.metaChar;
          tokens.add(Token(c, Type.operand));
          break;
        }
        tokens.add(Token(c, Type.operand));
        break;
      case _State.metaChar:
        if (c == quote) {
          // |LABEL   DC      'it''a small world'
          // |````````````````````^
          state = _State.string;
          tokens.add(Token(c, Type.operand));
          break;
        }
        if (c == newline) {
          // |LABEL   DC      'hello, world'\n
          // |``````````````````````````````^
          state = _State.label;
          tokens.add(Token(c, Type.endLine));
          break;
        }
        if (c == tab || c == space) {
          // |LABEL   DC      'hello, world'  comment
          // |``````````````````````````````^
          state = _State.endOperand;
          break;
        }
        // |LABEL   DC      'hello, world',-1
        // |``````````````````````````````^
        state = _State.operand;
        tokens.add(Token(c, Type.operand));
        break;
    }
  }
  return tokens;
}
