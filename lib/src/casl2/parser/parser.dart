import '../../typedef/typedef.dart';
import '../lexer/lexer.dart' show Lexer, Token;
import '../casl2.dart' show Casl2Error;
import './ast.dart';

export './ast.dart';

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

  void _skipBlankToken() {
    var token = _lexer.nextToken();
    while (token.isSpace || token.isEol || token.isComment) {
      token = _lexer.nextToken();
    }
    _lexer.keepToken(token);
  }

  void _skipSpaceToken() {
    var token = _lexer.nextToken();
    while (token.isSpace) {
      token = _lexer.nextToken();
    }
    _lexer.keepToken(token);
  }

  void _skipTokenOfLine() {
    var token = _lexer.nextToken();
    while (token.isNotEol && token.isNotEof) {
      token = _lexer.nextToken();
    }
    _lexer.keepToken(token);
  }

  /// is EOF or OPECODE(END)
  bool _isEnd() {
    final token = _lexer.peekToken();
    return token.isEof || (token.isOp && token.string == 'END');
  }

  Result<Token?, ParseError> _getLabel() {
    switch (_lexer.nextToken()) {
      case final token when token.isLabel:
        return Ok(token);
      case final token when token.isUnexpected:
        // skip line
        _skipTokenOfLine();

        return Err(ParseError.fromToken(
          '[SYNTAX ERROR] Unexpected Label: $token',
          token,
        ));
      case final token:
        _lexer.keepToken(token);
        return Ok(null);
    }
  }

  Result<Token, ParseError> _getOpecode() {
    _skipSpaceToken();
    switch (_lexer.nextToken()) {
      case final token when token.isOp:
        return Ok(token);
      case final token:
        // skip line
        _skipTokenOfLine();

        return Err(ParseError.fromToken(
          '[SYNTAX ERROR] Unexpected token: $token',
          token,
        ));
    }
  }

  Result<List<Token>, ParseError> _getOperand() {
    final operand = <Token>[];

    loop:
    while (true) {
      switch (_lexer.nextToken()) {
        case final token
            when token.isSpace || token.isSeparation || token.isComment:
          break;
        case final token when token.isLabel || token.isOp || token.isUnexpected:
          // skip line
          _skipTokenOfLine();

          return Err(ParseError.fromToken(
            '[SYNTAX ERROR] Unexpected Token: $token',
            token,
          ));
        case final token when token.isEof || token.isEol:
          break loop;
        case final token:
          operand.add(token);
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
      if (_isEnd()) return;

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
