import 'package:tiamat/typedef.dart';
import './lexer.dart' show Lexer, TokenizeError, Token;
import './casl2.dart' show Casl2Error;
import './parser/ast.dart';

export './parser/ast.dart';

//// Error of Parser
final class ParseError extends Casl2Error {
  const ParseError(
    super.message, {
    required super.start,
    required super.end,
    required super.lineStart,
    required super.lineNumber,
  });

  factory ParseError.fromToken(String message, Token token) => ParseError(
        message,
        start: token.start,
        end: token.end,
        lineStart: token.lineStart,
        lineNumber: token.lineNumber,
      );
}

/// Parser of CASL2
abstract class Parser {
  Iterable<Result<Statement, ParseError>> nextStatement();

  /// Create a parser instance.
  factory Parser(Lexer lexer) => _Parser(lexer);
}

class _Parser implements Parser {
  final Lexer _lexer;

  _Parser(this._lexer);

  Result<void, TokenizeError> _skipBlankToken() {
    var token = _lexer.nextToken();
    if (token.isErr) return Err(token.err);
    while (token.isOk &&
        (token.ok.isSpace || token.ok.isEol || token.ok.isComment)) {
      token = _lexer.nextToken();
    }

    return token.map((token) => _lexer.keepToken(token));
  }

  Result<void, TokenizeError> _skipSpaceToken() {
    var token = _lexer.nextToken();
    if (token.isErr) return Err(token.err);
    while (token.isOk && token.ok.isSpace) {
      token = _lexer.nextToken();
    }

    return token.map((token) => _lexer.keepToken(token));
  }

  Result<void, TokenizeError> _skipTokenOfLine() {
    var token = _lexer.nextToken();
    if (token.isErr) return Err(token.err);
    while (token.isOk && token.ok.isNotEol && token.ok.isNotEof) {
      token = _lexer.nextToken();
    }

    return token.map((token) => _lexer.keepToken(token));
  }

  /// is EOF or OPECODE(END)
  Result<bool, TokenizeError> _isEnd() {
    return _lexer.peekToken().map((token) {
      return token.isEof || (token.isOp && token.string == 'END');
    });
  }

  Result<Token?, ParseError> _getLabel() {
    _skipSpaceToken();
    final token = _lexer.nextToken().map((token) {
      if (token.isLabel) return token;
      _lexer.keepToken(token);
      return null;
    });
    if (token.isErr) {
      // skip line
      _skipTokenOfLine();

      final err = token.err;
      return Err(ParseError.fromToken(
        '[SYNTAX ERROR] ${err.message}',
        err.token,
      ));
    }
    return Ok(token.ok);
  }

  Result<Token, ParseError> _getOpecode() {
    {
      final result = _skipSpaceToken();
      if (result.isErr) {
        final err = result.err;
        return Err(ParseError.fromToken(
          '[SYNTAX ERROR] ${err.message}',
          err.token,
        ));
      }
    }

    final token = _lexer.nextToken();
    if (token.isErr) {
      // skip line
      _skipTokenOfLine();

      final err = token.err;
      return Err(ParseError.fromToken(
        '[SYNTAX ERROR] ${err.message}',
        err.token,
      ));
    }
    switch (token.ok) {
      case final token when token.isOp:
        return Ok(token);
      default:
        // skip line
        _skipTokenOfLine();

        return Err(ParseError.fromToken(
          '[SYNTAX ERROR] Unexpected token: ${token.ok}',
          token.ok,
        ));
    }
  }

  Result<List<Token>, ParseError> _getOperand() {
    final operand = <Token>[];

    loop:
    while (true) {
      final token = _lexer.nextToken();
      if (token.isErr) {
        // skip line
        _skipTokenOfLine();

        final err = token.err;
        return Err(ParseError.fromToken(
          '[SYNTAX ERROR] ${err.message}',
          err.token,
        ));
      }

      switch (token.ok) {
        case final token
            when token.isSpace || token.isSeparation || token.isComment:
          break;
        case final token when token.isLabel || token.isOp:
          // skip line
          _skipTokenOfLine();

          return Err(ParseError.fromToken(
            '[SYNTAX ERROR] Unexpected token: $token',
            token,
          ));
        case final token when token.isEof || token.isEol:
          break loop;
        default:
          operand.add(token.ok);
      }
    }
    return Ok(operand);
  }

  /// make block-node
  Result<Statement, ParseError> _nextSubroutine(Statement start) {
    final stmtList = <Statement>[];
    for (final result in nextStatement()) {
      if (result.isErr) return result;
      stmtList.add(result.ok);
    }
    _skipTokenOfLine();

    return Ok(Statement.subroutine(start, process: stmtList));
  }

  /// return a parsed result.
  ///
  /// EOF or OPECODE(END) is true, finish parsing.
  @override
  Iterable<Result<Statement, ParseError>> nextStatement() sync* {
    while (true) {
      _skipBlankToken();
      {
        final end = _isEnd();
        if (end.isOk && end.ok) {
          return;
        }
        if (end.isErr) {
          final err = end.err;

          yield Err(ParseError.fromToken(
            '[SYNTAX ERROR] ${err.message}',
            err.token,
          ));
        }
      }

      final label = _getLabel();
      if (label.isErr) {
        yield Err(label.err);
        continue;
      }

      final opecode = _getOpecode();
      if (opecode.isErr) {
        yield Err(opecode.err);
        continue;
      }

      final operand = _getOperand();
      if (operand.isErr) {
        yield Err(operand.err);
        continue;
      }

      final stmt = Statement(
        opecode.ok,
        label: label.ok,
        operand: operand.ok,
      );

      if (stmt.opecode.string == 'START') {
        yield _nextSubroutine(stmt);
      } else {
        yield Ok(stmt);
      }
    }
  }
}
