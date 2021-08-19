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

/// lexical analysis.
class Lexer {
  late final List<int> _runes;
  var _currentIndex = 0;
  var _currentLine = 0;
  var _currentLineStartIndex = 0;

  /// lexical state.
  var _expectedStatus = ExpectedStatus.label;

  Lexer(String str) {
    _runes = str.runes.toList(growable: false);
  }

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
        return _getToken(start, end, TokenType.label);
      case ExpectedStatus.expectOpecode:
        _skipSpace();
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
        _skipSpace();
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
          _readChar();
          return nextToken();
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
          return _getToken(start, end, TokenType.string);
        }

        if (_isGR) {
          final start = _currentIndex;
          _readIdent();
          final end = _currentIndex;
          return _getToken(start, end, TokenType.gr);
        }

        final start = _currentIndex;
        _readIdent();
        final end = _currentIndex;

        return _getToken(start, end, TokenType.ident);
      case ExpectedStatus.expectComment:
        _skipSpace();
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
        _currentLine += 1;
        _currentLineStartIndex = _currentIndex;
        return eol;
    }
  }

  Token _getToken(int start, int end, TokenType type) {
    return Token(
      _runes.getRange(start, end),
      type,
      start: start,
      end: end,
      line: _currentLine,
      lineStart: start - _currentLineStartIndex,
      lineEnd: end - _currentLineStartIndex,
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

  void _skipSpace() {
    while (!isLast && _isSpace) {
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
  bool get _isGR => () {
        final start = _currentIndex;
        final end = start + 3;
        switch (String.fromCharCodes(_runes.getRange(start, end))) {
          case 'GR0':
          case 'GR1':
          case 'GR2':
          case 'GR3':
          case 'GR4':
          case 'GR5':
          case 'GR6':
          case 'GR7':
            if (_isLast(end) ||
                isSpace(_runes[end]) ||
                isSeparation(_runes[end])) {
              return true;
            }
            return false;
          default:
            return false;
        }
      }();
  bool get _isString => current == quote;
  bool get _isSeparation => isSeparation(current);
  bool get _isNewline => isNewline(current);
  bool _isLast(final int index) => index >= _runes.length;

  bool get isLast => _isLast(_currentIndex);

  int? get current => () {
        if (isLast) {
          return null;
        }
        return _runes[_currentIndex];
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
