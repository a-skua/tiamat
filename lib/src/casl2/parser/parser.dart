import './ast.dart';
import '../lexer/lexer.dart';
import '../lexer/token.dart';
import './util.dart';
import '../compiler/state.dart';
import '../../typedef/typedef.dart';

//// Error of Parser
final class ParseError {
  final String message;
  final int start;
  final int end;
  final int lineStart;
  final int lineNumber;

  ParseError(
    this.message, {
    required this.start,
    required this.end,
    required this.lineStart,
    required this.lineNumber,
  });

  factory ParseError.fromToken(String message, Token token) => ParseError(
        message,
        start: token.start,
        end: token.end,
        lineStart: token.lineStart,
        lineNumber: token.lineNumber,
      );

  @deprecated
  factory ParseError.todo(String msg) => ParseError(
        msg,
        start: 0,
        end: 0,
        lineStart: 0,
        lineNumber: 0,
      );

  @override
  String toString() => 'L$lineNumber: $message';
}

/// Parser of CASL2
abstract class Parser {
  Iterable<Result<Statement, ParseError>> nextStatement(State state);

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
        (token.ok.type == TokenType.space ||
            token.ok.type == TokenType.eol ||
            token.ok.type == TokenType.comment)) {
      token = _lexer.nextToken();
    }

    if (token.isErr) return Err(token.err);
    _lexer.keepToken(token.ok);
    return Ok(null);
  }

  Result<void, TokenizeError> _skipSpaceToken() {
    var token = _lexer.nextToken();
    if (token.isErr) return Err(token.err);
    while (token.isOk && token.ok.type == TokenType.space) {
      token = _lexer.nextToken();
    }

    if (token.isErr) return Err(token.err);
    _lexer.keepToken(token.ok);
    return Ok(null);
  }

  Result<void, TokenizeError> _skipTokenOfLine() {
    var token = _lexer.nextToken();
    if (token.isErr) return Err(token.err);
    while (token.isOk &&
        token.ok.type != TokenType.eol &&
        token.ok.type != TokenType.eof) {
      token = _lexer.nextToken();
    }
    if (token.isErr) return Err(token.err);
    _lexer.keepToken(token.ok);
    return Ok(null);
  }

  /// is EOF or OPECODE(END)
  Result<bool, TokenizeError> _isEnd() {
    final token = _lexer.peekToken();
    if (token.isErr) return Err(token.err);
    if (token.ok.type != TokenType.eof &&
        (String.fromCharCodes(token.ok.runes) != 'END' ||
            token.ok.type != TokenType.op)) {
      return Ok(false);
    }

    return Ok(true);
  }

  Result<Token?, ParseError> _getLabel() {
    _skipSpaceToken();
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
    switch (token.ok.type) {
      case TokenType.label:
        return Ok(token.ok);
      default:
        _lexer.keepToken(token.ok);
        return Ok(null);
    }
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
    switch (token.ok.type) {
      case TokenType.op:
        return Ok(token.ok);
      default:
        // skip line
        {
          final result = _skipTokenOfLine();
          if (result.isErr) {
            final err = result.err;
            return Err(ParseError.fromToken(
              '[SYNTAX ERROR] ${err.message}',
              err.token,
            ));
          }
        }

        return Err(ParseError(
          '[SYNTAX ERROR] Unexpected token: ${token.ok}',
          start: token.ok.start,
          end: token.ok.end,
          lineStart: token.ok.lineStart,
          lineNumber: token.ok.lineNumber,
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

      switch (token.ok.type) {
        case TokenType.space:
        case TokenType.separation:
        case TokenType.comment:
          break;
        case TokenType.label:
        case TokenType.op:
          // skip line
          _skipTokenOfLine();

          return Err(ParseError.fromToken(
            '[SYNTAX ERROR] Unexpected token: ${token.ok}',
            token.ok,
          ));
        case TokenType.eof:
        case TokenType.eol:
          break loop;
        default:
          operand.add(token.ok);
      }
    }
    return Ok(operand);
  }

  /// make block-node
  Result<Statement, ParseError> _nextSubroutine(Statement start, State state) {
    final stmtList = <Statement>[];
    for (final result in nextStatement(state)) {
      if (result.isErr) return result;
      stmtList.add(result.ok);
    }

    return Ok(Statement.subroutine(start, process: stmtList));
  }

  /// return a parsed result.
  ///
  /// EOF or OPECODE(END) is true, finish parsing.
  @override
  Iterable<Result<Statement, ParseError>> nextStatement(State state) sync* {
    while (true) {
      _skipBlankToken();
      {
        final end = _isEnd();
        if (end.isOk && end.ok) {
          return;
        }
        if (end.isErr) {
          final err = end.err;

          yield Err(ParseError(
            '[SYNTAX ERROR] ${err.message}',
            start: err.token.start,
            end: err.token.end,
            lineStart: err.token.lineStart,
            lineNumber: err.token.lineNumber,
          ));
        }
      }

      final label = _getLabel();
      if (label.isErr) yield Err(label.err);

      final opecode = _getOpecode();
      if (opecode.isErr) yield Err(opecode.err);

      final operand = _getOperand();
      if (operand.isErr) yield Err(operand.err);

      final stmt = Statement(
        opecode.ok,
        label: label.ok,
        operand: operand.ok,
      );

      if (label.ok != null) {
        state.setLabel(stmt);
      }

      if (String.fromCharCodes(stmt.opecode.runes) == 'START') {
        yield _nextSubroutine(stmt, state);
      } else {
        yield Ok(stmt);
      }
    }
  }
}

/// TODO parser
Result<List<Code>, ParseError> _parse(Statement stmt, State state) {
  switch (String.fromCharCodes(stmt.opecode.runes)) {
    case 'LD':
    case 'ADDA':
    case 'SUBA':
    case 'ADDL':
    case 'SUBL':
    case 'AND':
    case 'OR':
    case 'XOR':
    case 'CPA':
    case 'CPL':
      return parseGeneral(stmt, state);
    case 'ST':
    case 'LAD':
    case 'SLA':
    case 'SRA':
    case 'SLL':
    case 'SRL':
      return parseRadrx(stmt, state);
    case 'JMI':
    case 'JNZ':
    case 'JZE':
    case 'JUMP':
    case 'JPL':
    case 'JOV':
    case 'PUSH':
    case 'CALL':
    case 'SVC':
      return parseAdrx(stmt, state);
    case 'POP':
      return parseR(stmt, state);
    case 'RET':
      return Ok([Code((_) => 0x8100)]);
    case 'NOP':
      return Ok([Code((_) => 0)]);
    case '':
    case 'START':
    case 'END':
      return Ok([]);
    case 'DC':
      return parseDC(stmt, state);
    case 'DS':
      return parseDS(stmt, state);
    default:
      return parseMacro(stmt as Macro, state);
  }
}
