import '../token/token.dart';

/// space
final space = ' '.runes.first;
final tab = '\t'.runes.first;

/// newline
final ret = '\r'.runes.first;
final newline = '\n'.runes.first;

/// comment
final semicolon = ';'.runes.first;

const tokenEOF = Token([], TokenType.eof);
const tokenEOL = Token([], TokenType.eol);

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
        return Token(_runes.getRange(start, end), TokenType.label);
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
        return Token(_runes.getRange(start, end), TokenType.opecode);
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

        final start = _currentIndex;
        _readOperand();
        final end = _currentIndex;

        _expectedStatus = ExpectedStatus.expectComment;
        return Token(_runes.getRange(start, end), TokenType.operand);
      case ExpectedStatus.expectComment:
        _skipSpace();
        _expectedStatus = ExpectedStatus.comment;
        return nextToken();
      case ExpectedStatus.comment:
        final start = _currentIndex;
        _readComment();
        final end = _currentIndex;

        _expectedStatus = ExpectedStatus.eol;
        return Token(_runes.getRange(start, end), TokenType.comment);
      case ExpectedStatus.eol:
        _expectedStatus = ExpectedStatus.label;
        _readChar();
        return tokenEOL;
    }
  }

  void _readLabel() => _readLetter();

  void _readOpecode() => _readLetter();

  void _readOperand() => _readLetter();

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

  bool get _isSpace => current == space || current == tab;
  bool get _isComment => current == semicolon;
  bool get _isNewline => current == ret || current == newline;

  bool get isLast => _currentIndex >= _runes.length;

  int get current => _runes[_currentIndex];
}
