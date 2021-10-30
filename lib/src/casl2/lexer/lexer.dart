import 'dart:collection';
import '../token/token.dart';

/// space
final space = ' '.runes.first;
final tab = '\t'.runes.first;

/// newline
final newline = '\n'.runes.first;

/// comment
final semicolon = ';'.runes.first;

final comma = ','.runes.first;
final sharp = '#'.runes.first;
final minus = '-'.runes.first;
final quote = '\''.runes.first;
final decNumbers = HashSet<int>.from('0123456789'.runes);
final hexNumbers = HashSet<int>.from(decNumbers)..addAll('ABCDEF'.runes);

bool isSpace(final int? rune) => rune == space || rune == tab;
bool isNewline(final int? rune) => rune == newline;
bool isSeparation(final int? rune) => rune == comma;

const tokenEOF = Token([], TokenType.eof);

/// expected current status.
enum ExpectedStatus {
  label,
  expectOperand,
  operand,
  expectOpecode,
  opecode,
  expectComment,
  comment,
  eol,
}

abstract class LexerInterface {
  Token nextToken();
}

/// lexical analysis.
class Lexer implements LexerInterface {
  late final List<int> _runes;
  var _currentIndex = 0;
  var _currentLineNumber = 1;
  var _currentLineStart = 0;

  /// lexical state.
  var _expectedStatus = ExpectedStatus.label;

  Lexer(Iterable<int> runes) {
    _runes = runes.toList();
  }

  factory Lexer.fromString(String src) {
    return Lexer(src.runes);
  }

  @override
  Token nextToken() {
    if (isLast) {
      return tokenEOF;
    }

    switch (_expectedStatus) {
      case ExpectedStatus.label:
        if (_isSpace) {
          _expectedStatus = ExpectedStatus.expectOpecode;
          return nextToken();
        }

        if (_isComment) {
          _expectedStatus = ExpectedStatus.comment;
          return nextToken();
        }

        if (_isNewline) {
          _expectedStatus = ExpectedStatus.eol;
          return nextToken();
        }

        final start = _currentIndex;
        _readLabel();
        final end = _currentIndex;
        _expectedStatus = ExpectedStatus.expectOpecode;

        if (_isGR(start, end)) {
          final gr = String.fromCharCodes(_runes.getRange(start, end));
          return _getError(start, end, '$gr cannot be used as label');
        }
        return _getToken(start, end, TokenType.label);
      case ExpectedStatus.expectOpecode:
        if (_isSpace) {
          return _getSpace();
        }

        if (_isComment) {
          _expectedStatus = ExpectedStatus.comment;
          return nextToken();
        }

        _expectedStatus = ExpectedStatus.opecode;
        return nextToken();
      case ExpectedStatus.opecode:
        if (_isNewline) {
          _expectedStatus = ExpectedStatus.eol;
          return nextToken();
        }

        final start = _currentIndex;
        _readOpecode();
        final end = _currentIndex;

        _expectedStatus = ExpectedStatus.expectOperand;
        return _getToken(start, end, TokenType.opecode);
      case ExpectedStatus.expectOperand:
        if (_isSpace) {
          return _getSpace();
        }

        if (_isComment) {
          _expectedStatus = ExpectedStatus.comment;
          return nextToken();
        }

        _expectedStatus = ExpectedStatus.operand;
        return nextToken();
      case ExpectedStatus.operand:
        if (_isNewline) {
          _expectedStatus = ExpectedStatus.eol;
          return nextToken();
        }

        if (_isSeparation) {
          final start = _currentIndex;
          _readChar();
          final end = _currentIndex;
          return _getToken(start, end, TokenType.separation);
        }

        if (_isSpace) {
          _expectedStatus = ExpectedStatus.expectComment;
          return nextToken();
        }

        if (_isDec) {
          final start = _currentIndex;
          _readDec();
          final end = _currentIndex;
          return _getToken(start, end, TokenType.dec);
        }

        if (_isHex) {
          final start = _currentIndex;
          _readHex();
          final end = _currentIndex;
          return _getToken(start, end, TokenType.hex);
        }

        if (_isString) {
          final start = _currentIndex;
          _readString();
          final end = _currentIndex;
          if (_previous != quote) {
            return _getError(start, end, 'Invalid String.');
          }
          return _getToken(start, end, TokenType.string);
        }

        final start = _currentIndex;
        _readIdent();
        final end = _currentIndex;

        if (_isGR(start, end)) {
          return _getToken(start, end, TokenType.gr);
        }
        return _getToken(start, end, TokenType.ident);
      case ExpectedStatus.expectComment:
        if (_isSpace) {
          return _getSpace();
        }

        _expectedStatus = ExpectedStatus.comment;
        return nextToken();
      case ExpectedStatus.comment:
        final start = _currentIndex;
        _readComment();
        final end = _currentIndex;

        _expectedStatus = ExpectedStatus.eol;
        return _getToken(start, end, TokenType.comment);
      case ExpectedStatus.eol:
        _expectedStatus = ExpectedStatus.label;
        final start = _currentIndex;
        final eol = _getToken(start, start + 1, TokenType.eol);
        _readChar();
        _currentLineStart = _currentIndex;
        _currentLineNumber += 1;
        return eol;
    }
  }

  Token _getSpace() {
    final start = _currentIndex;
    while (!isLast && _isSpace) {
      _readChar();
    }
    final end = _currentIndex;

    return Token(
      _runes.getRange(start, end),
      TokenType.space,
      start: start,
      end: end,
      lineStart: _currentLineStart,
      lineNumber: _currentLineNumber,
    );
  }

  Token _getToken(int start, int end, TokenType type) {
    return Token(
      _runes.getRange(start, end),
      type,
      start: start,
      end: end,
      lineStart: _currentLineStart,
      lineNumber: _currentLineNumber,
    );
  }

  Token _getError(int start, int end, String error) {
    return ErrorToken(
      _runes.getRange(start, end),
      error,
      start: start,
      end: end,
      lineNumber: _currentLineNumber,
      lineStart: _currentLineStart,
    );
  }

  void _readLabel() => _readLetter();

  void _readOpecode() => _readLetter();

  void _readIdent() {
    while (!isLast && !_isSpace && !_isNewline && !_isSeparation) {
      _readChar();
    }
  }

  void _readDec() {
    _readChar();
    while (_isDecNumber) {
      _readChar();
    }
  }

  void _readHex() {
    _readChar();
    while (hexNumbers.contains(current)) {
      _readChar();
    }
  }

  void _readString() {
    _readChar();
    while (true) {
      if (current == quote && _next == quote) {
        _readChar();
      } else if (current == quote) {
        _readChar();
        break;
      } else if (isLast || _isNewline) {
        break;
      }
      _readChar();
    }
  }

  void _readComment() {
    while (!isLast && !_isNewline) {
      _readChar();
    }
  }

  void _readLetter() {
    while (!isLast && !_isSpace && !_isNewline) {
      _readChar();
    }
  }

  void _readChar() {
    if (isLast) {
      return;
    }
    _currentIndex += 1;
  }

  bool get _isSpace => isSpace(current);
  bool get _isComment => current == semicolon;
  bool get _isDec => current == minus || _isDecNumber;
  bool get _isDecNumber => decNumbers.contains(current);
  bool get _isHex => current == sharp;
  bool get _isString => current == quote;
  bool get _isSeparation => isSeparation(current);
  bool get _isNewline => isNewline(current);
  bool _isLast(final int index) => index >= _runes.length;

  bool _isGR(int start, int end) {
    switch (String.fromCharCodes(_runes.getRange(start, end))) {
      case 'GR0':
      case 'GR1':
      case 'GR2':
      case 'GR3':
      case 'GR4':
      case 'GR5':
      case 'GR6':
      case 'GR7':
        return true;
      default:
        return false;
    }
  }

  bool get isLast => _isLast(_currentIndex);

  int? get current => () {
        if (isLast) {
          return null;
        }
        return _runes[_currentIndex];
      }();

  int? get _previous => () {
        if (_currentIndex == 0) {
          return null;
        }
        return _runes[_currentIndex - 1];
      }();

  int? get _next => () {
        final nextIndex = _currentIndex + 1;
        if (nextIndex >= _runes.length) {
          return null;
        }
        return _runes[nextIndex];
      }();

  List<int> _range(final int start, final int end) {
    if (start < 0 || end >= _runes.length) {
      return [];
    }
    return List.from(_runes.getRange(start, end));
  }
}
