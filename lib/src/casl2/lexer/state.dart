import './token.dart' show Rune, Token;

/// space
final _space = ' '.runes.first;
final _tab = '\t'.runes.first;

/// newline
final _newline = '\n'.runes.first;

/// comment
final _semicolon = ';'.runes.first;

final _comma = ','.runes.first;
final _sharp = '#'.runes.first;
final _minus = '-'.runes.first;
final _quote = '\''.runes.first;
final _backslash = '\\'.runes.first;
final _alphabet = Set<Rune>.from('ABCDEFGHIJKLMNOPQRSTUVWXYZ'.runes);
final _decNumbers = Set<Rune>.from('0123456789'.runes);
final _hexNumbers = Set<Rune>.from(_decNumbers)..addAll('ABCDEF'.runes);
final _gr = Set<String>.from({
  'GR0',
  'GR1',
  'GR2',
  'GR3',
  'GR4',
  'GR5',
  'GR6',
  'GR7',
});

extension RuneExt on Rune {
  bool get isSpace => this == _space || this == _tab;
  bool get isNotSpace => !isSpace;

  bool get isNewline => this == _newline;
  bool get isNotNewline => !isNewline;

  bool get isAlphabet => _alphabet.contains(this);
  bool get isNotAlphabet => !isAlphabet;

  bool get isSeparation => this == _comma;
  bool get isNotSeparation => !isSeparation;

  bool get isQuote => this == _quote;
  bool get isNotQuote => !isQuote;

  bool get isBackslash => this == _backslash;
  bool get isNotBackslash => !isBackslash;

  bool get isSemicolon => this == _semicolon;
  bool get isNotSemicolon => !isSemicolon;

  bool get isMinus => this == _minus;
  bool get isNotMinus => !isMinus;

  bool get isSharp => this == _sharp;
  bool get isNotSharp => !isSharp;

  bool get isDec => _decNumbers.contains(this);
  bool get isNotDec => !isDec;

  bool get isHex => _hexNumbers.contains(this);
  bool get isNotHex => !isHex;
}

extension RunesExt on List<Rune> {
  bool get isGR {
    final str = String.fromCharCodes(this);
    return _gr.contains(str);
  }
}

final class Runes {
  final List<Rune> _runes;

  /// cursor.
  int _cursor = 0;
  int get cursor => _cursor;

  /// line number.
  ///
  /// e.g.
  /// MAIN  START <- line 1
  int _lineNumber = 1;
  int get lineNumber => _lineNumber;

  /// cursor of line.
  ///
  /// e.g.
  /// MAIN  START
  /// ^
  /// |_ lineStart
  int _lineStart = 0;
  int get lineStart => _lineStart;

  Runes(this._runes);

  Rune get(int index) {
    return _runes[index];
  }

  bool get isEnd => _cursor >= _runes.length;
  bool get isNotEnd => !isEnd;

  Rune? read() {
    if (isNotEnd && current == _newline) {
      _lineNumber += 1;
      _lineStart = _cursor + 1;
    }

    _cursor += 1;
    if (isEnd) return null;
    return current;
  }

  Rune get current => _runes[_cursor];
  Rune? get previous => _cursor == 0 ? null : _runes[_cursor - 1];
  Rune? get next => _cursor + 1 >= _runes.length ? null : _runes[_cursor + 1];

  List<Rune> sublist(int start, int end) {
    return _runes.sublist(start, end);
  }
}

extension ReadRunes on Runes {
  Token readLabel() {
    final start = cursor;
    while (true) {
      final rune = read();
      if (rune == null || (rune.isNotAlphabet && rune.isNotDec)) {
        break;
      }
    }
    final end = cursor;

    final runes = sublist(start, end);
    if (runes.isGR) {
      return Token.unexpected(
        runes,
        start: start,
        end: end,
        lineStart: lineStart,
        lineNumber: lineNumber,
      );
    }

    return Token.label(
      runes,
      start: start,
      end: end,
      lineStart: lineStart,
      lineNumber: lineNumber,
    );
  }

  Token readOpecode() {
    final start = cursor;
    while (true) {
      final rune = read();
      if (rune == null || rune.isNotAlphabet) {
        break;
      }
    }
    final end = cursor;

    return Token.op(
      sublist(start, end),
      start: start,
      end: end,
      lineStart: lineStart,
      lineNumber: lineNumber,
    );
  }

  Token readUnexpected() {
    final start = cursor;
    while (true) {
      final rune = read();
      if (rune == null || rune.isSpace || rune.isNewline) {
        break;
      }
    }
    final end = cursor;

    return Token.unexpected(
      sublist(start, end),
      start: start,
      end: end,
      lineStart: lineStart,
      lineNumber: lineNumber,
    );
  }

  Token readSpace() {
    final start = cursor;
    while (true) {
      final rune = read();
      if (rune == null || rune.isNotSpace) {
        break;
      }
    }
    final end = cursor;

    return Token.space(
      sublist(start, end),
      start: start,
      end: end,
      lineStart: lineStart,
      lineNumber: lineNumber,
    );
  }

  Token readDec() {
    final start = cursor;
    while (true) {
      final rune = read();
      if (rune == null || rune.isNotDec) {
        break;
      }
    }
    final end = cursor;

    if (isNotEnd &&
        current.isNotSpace &&
        current.isNotSeparation &&
        current.isNotNewline) {
      return Token.unexpected(
        sublist(start, end),
        start: start,
        end: end,
        lineStart: lineStart,
        lineNumber: lineNumber,
      );
    }

    return Token.dec(
      sublist(start, end),
      start: start,
      end: end,
      lineStart: lineStart,
      lineNumber: lineNumber,
    );
  }

  Token readHex() {
    final start = cursor;
    while (true) {
      final rune = read();
      if (rune == null || rune.isNotHex) {
        break;
      }
    }
    final end = cursor;

    if (end - start != 5) {
      return Token.unexpected(
        sublist(start, end),
        start: start,
        end: end,
        lineStart: lineStart,
        lineNumber: lineNumber,
      );
    }

    if (isNotEnd &&
        current.isNotSpace &&
        current.isNotSeparation &&
        current.isNotNewline) {
      return Token.unexpected(
        sublist(start, end),
        start: start,
        end: end,
        lineStart: lineStart,
        lineNumber: lineNumber,
      );
    }

    return Token.hex(
      sublist(start, end),
      start: start,
      end: end,
      lineStart: lineStart,
      lineNumber: lineNumber,
    );
  }

  Token readText() {
    final start = cursor;
    var state = Text.firstQuote;
    while (true) {
      final rune = read();
      if (rune == null) break;

      state = state.next(rune);
      if (state.isEnd) break;
    }
    final end = cursor;

    if (state.isInvalid ||
        (isNotEnd &&
            current.isNotSpace &&
            current.isNotSeparation &&
            current.isNotNewline)) {
      return Token.unexpected(
        sublist(start, end),
        start: start,
        end: end,
        lineStart: lineStart,
        lineNumber: lineNumber,
      );
    }

    return Token.text(
      sublist(start, end),
      start: start,
      end: end,
      lineStart: lineStart,
      lineNumber: lineNumber,
    );
  }

  Token readRef() {
    final start = cursor;
    while (true) {
      final rune = read();
      if (rune == null || (rune.isNotAlphabet && rune.isNotDec)) {
        break;
      }
    }
    final end = cursor;

    final runes = sublist(start, end);
    if (isNotEnd &&
        current.isNotSpace &&
        current.isNotSeparation &&
        current.isNotNewline) {
      return Token.unexpected(
        runes,
        start: start,
        end: end,
        lineStart: lineStart,
        lineNumber: lineNumber,
      );
    }

    if (runes.isGR) {
      return Token.gr(
        runes,
        start: start,
        end: end,
        lineStart: lineStart,
        lineNumber: lineNumber,
      );
    }

    return Token.ref(
      runes,
      start: start,
      end: end,
      lineStart: lineStart,
      lineNumber: lineNumber,
    );
  }

  Token readSeparator() {
    final start = cursor;
    read();
    final end = cursor;

    return Token.separation(
      sublist(start, end),
      start: start,
      end: end,
      lineStart: lineStart,
      lineNumber: lineNumber,
    );
  }

  Token readComment() {
    final start = cursor;
    while (true) {
      final rune = read();
      if (rune == null || rune.isNewline) {
        break;
      }
    }
    final end = cursor;

    return Token.comment(
      sublist(start, end),
      start: start,
      end: end,
      lineStart: lineStart,
      lineNumber: lineNumber,
    );
  }

  Token readNewliine() {
    final start = cursor;
    read();
    final end = cursor;

    return Token.eol(
      sublist(start, end),
      start: start,
      end: end,
      lineStart: lineStart,
      lineNumber: lineNumber,
    );
  }
}

/// Statement
///
/// ```
/// STATEMENT:
/// ExpectLabel --> Label --> ExpectOpecode --> Opecode --> Space --> ExpectOperand --> OPERAND --> Space -> Comment -> EOL
///                                                                                 `-> Comment --> EOL
/// ExpectLabel --> ExpectOpecode --> Opecode --> Space --> ExpectOperand --> OPERAND --> Space -> Comment -> EOL
///                               |                                       `-> Comment --> EOL
///                               `-> Comment --> EOL
/// OPERAND:
/// ExpectOperand --> Register  --> Comma --> OPERAND
///               |-> Register  --> ExpectComment
///               |-> Reference --> Comma --> OPERAND
///               |-> Reference --> ExpectComment
///               |-> Hex       --> Comma --> OPERAND
///               |-> Hex       --> ExpectComment
///               |-> Dec       --> Comma --> OPERAND
///               `-> Dec       --> ExpectComment
/// ```
enum Statement {
  expectLabel,
  unexpectedLabel,
  label,
  expectOpecode,
  unexpectedOpecode,
  opecode,
  expectOperand,
  unexpectedOperand,
  dec,
  hex,
  text,
  ref,
  separator,
  expectComment,
  comment,
  eol,
}

extension StatementNext on Statement {
  Statement Function(Rune) get next => switch (this) {
        Statement.expectLabel => _expectLabel,
        Statement.unexpectedLabel => _unexpectedLabel,
        Statement.label => _label,
        Statement.expectOpecode => _expectOpecode,
        Statement.unexpectedOpecode => _unexpectedOpecode,
        Statement.opecode => _opecode,
        Statement.expectOperand => _expectedOperand,
        Statement.unexpectedOperand => _unexpectedOperand,
        Statement.dec => _dec,
        Statement.hex => _hex,
        Statement.text => _text,
        Statement.ref => _ref,
        Statement.separator => _separator,
        Statement.expectComment => _expectComment,
        Statement.comment => _comment,
        Statement.eol => _eol,
      };

  Statement _expectLabel(Rune rune) {
    if (rune.isSemicolon) return Statement.comment;
    if (rune.isNewline) return Statement.eol;
    if (rune.isSpace) return Statement.expectOpecode;
    if (rune.isNotAlphabet) return Statement.unexpectedLabel;
    return Statement.label;
  }

  Statement _unexpectedLabel(Rune rune) {
    if (rune.isNewline) return Statement.eol;
    if (rune.isSpace) return Statement.expectOpecode;
    return this;
  }

  Statement _label(Rune rune) {
    if (rune.isSpace) return Statement.expectOpecode;
    return this;
  }

  Statement _expectOpecode(Rune rune) {
    if (rune.isAlphabet) return Statement.opecode;
    if (rune.isSemicolon) return Statement.comment;
    if (rune.isNotSpace) return Statement.unexpectedOpecode;
    return this;
  }

  Statement _unexpectedOpecode(Rune rune) {
    if (rune.isNewline) return Statement.eol;
    if (rune.isSpace) return Statement.expectOperand;
    return this;
  }

  Statement _opecode(Rune rune) {
    if (rune.isSpace) return Statement.expectOperand;
    if (rune.isNewline) return Statement.eol;
    return this;
  }

  Statement _expectedOperand(Rune rune) {
    if (rune.isNewline) return Statement.eol;
    if (rune.isSemicolon) return Statement.comment;
    if (rune.isDec || rune.isMinus) return Statement.dec;
    if (rune.isSharp) return Statement.hex;
    if (rune.isQuote) return Statement.text;
    if (rune.isAlphabet) return Statement.ref;
    if (rune.isNotSpace) return Statement.unexpectedOperand;
    return this;
  }

  Statement _unexpectedOperand(Rune rune) {
    if (rune.isNewline) return Statement.eol;
    if (rune.isSpace) return Statement.expectComment;
    return this;
  }

  Statement _dec(Rune rune) {
    if (rune.isNewline) return Statement.eol;
    if (rune.isSpace) return Statement.expectComment;
    if (rune.isSeparation) return Statement.separator;
    return this;
  }

  Statement _hex(Rune rune) {
    if (rune.isNewline) return Statement.eol;
    if (rune.isSpace) return Statement.expectComment;
    if (rune.isSeparation) return Statement.separator;
    return this;
  }

  Statement _text(Rune rune) {
    if (rune.isNewline) return Statement.eol;
    if (rune.isSpace) return Statement.expectComment;
    if (rune.isSeparation) return Statement.separator;
    return this;
  }

  Statement _ref(Rune rune) {
    if (rune.isNewline) return Statement.eol;
    if (rune.isSpace) return Statement.expectComment;
    if (rune.isSeparation) return Statement.separator;
    return this;
  }

  Statement _separator(Rune rune) {
    if (rune.isDec || rune.isMinus) return Statement.dec;
    if (rune.isSharp) return Statement.hex;
    if (rune.isQuote) return Statement.text;
    if (rune.isAlphabet) return Statement.ref;
    if (rune.isNotSeparation) return Statement.expectOperand;
    return this;
  }

  Statement _expectComment(Rune rune) {
    if (rune.isNewline) return Statement.eol;
    if (rune.isNotSpace) return Statement.comment;
    return this;
  }

  Statement _comment(Rune rune) {
    if (rune.isNewline) return Statement.eol;
    return this;
  }

  Statement _eol(Rune rune) {
    if (rune.isNotNewline) return Statement.expectLabel;
    return this;
  }
}

enum Text {
  firstQuote,
  rune,
  expectEscape,
  escapeRune,
  end,
  invalid,
}

extension TextNext on Text {
  Text Function(Rune) get next => switch (this) {
        Text.firstQuote => _firstQuote,
        Text.rune => _rune,
        Text.expectEscape => _escapeEscape,
        Text.escapeRune => _escapeRune,
        Text.end => _end,
        Text.invalid => _invalid,
      };

  bool get isEnd => this == Text.end || isInvalid;
  bool get isInvalid => this == Text.invalid;

  Text _firstQuote(Rune rune) {
    return Text.rune;
  }

  Text _rune(Rune rune) {
    if (rune.isQuote) return Text.expectEscape;
    if (rune.isNewline) return Text.invalid;
    return this;
  }

  Text _escapeEscape(Rune rune) {
    if (rune.isQuote) return Text.escapeRune;
    return Text.end;
  }

  Text _escapeRune(Rune rune) {
    return Text.rune;
  }

  Text _end(Rune _) => this;
  Text _invalid(Rune _) => this;
}
