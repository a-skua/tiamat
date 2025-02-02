import './token.dart';
import './state.dart';

export './token.dart';

final _tokenEOF = Token.eof();

abstract class Lexer {
  Token nextToken();
  Token peekToken();
  void keepToken(Token token);

  Iterable<Token> tokenize();

  factory Lexer(Iterable<Rune> runes) => _Lexer(Runes(runes.toList()));
  factory Lexer.fromString(String src) => _Lexer(Runes(src.runes.toList()));
}

/// lexical analysis.
final class _Lexer implements Lexer {
  final _keepToken = <Token>[];

  final Runes _runes;
  Statement _state = Statement.expectLabel;

  _Lexer(this._runes);

  @override
  Iterable<Token> tokenize() sync* {
    while (true) {
      final token = nextToken();
      if (token == _tokenEOF) {
        break;
      }
      yield token;
    }
  }

  @override
  Token peekToken() {
    final token = nextToken();
    keepToken(token);
    return token;
  }

  @override
  void keepToken(Token token) {
    _pushToken(token);
  }

  bool get _hasToken => _keepToken.isNotEmpty;
  void _pushToken(Token token) => _keepToken.add(token);
  Token _popToken() => _keepToken.removeLast();

  @override
  Token nextToken() {
    if (_hasToken) return _popToken();

    if (_runes.isEnd) return _tokenEOF;

    _state = _state.next(_runes.current);
    return switch (_state) {
      Statement.expectLabel => nextToken(),
      Statement.unexpectedLabel => _runes.readUnexpected(),
      Statement.label => _runes.readLabel(),
      Statement.expectOpecode => _runes.readSpace(),
      Statement.unexpectedOpecode => _runes.readUnexpected(),
      Statement.opecode => _runes.readOpecode(),
      Statement.expectOperand => _runes.readSpace(),
      Statement.unexpectedOperand => _runes.readUnexpected(),
      Statement.dec => _runes.readDec(),
      Statement.hex => _runes.readHex(),
      Statement.text => _runes.readText(),
      Statement.ref => _runes.readRef(),
      Statement.separator => _runes.readSeparator(),
      Statement.expectComment => _runes.readSpace(),
      Statement.comment => _runes.readComment(),
      Statement.eol => _runes.readNewliine(),
    };
  }
}
