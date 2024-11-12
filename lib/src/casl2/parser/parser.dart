import '../ast/ast.dart';
import '../lexer/lexer.dart';
import '../token/token.dart';
import './util.dart';
import './state.dart';
import '../typedef.dart';
export './state.dart';

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
    if (token.isError) return Result.err(token.error);
    while (token.isOk &&
        (token.ok.type == TokenType.space ||
            token.ok.type == TokenType.eol ||
            token.ok.type == TokenType.comment)) {
      token = _lexer.nextToken();
    }

    if (token.isError) return Result.err(token.error);
    _lexer.keepToken(token.ok);
    return Result.ok(null);
  }

  Result<void, TokenizeError> _skipSpaceToken() {
    var token = _lexer.nextToken();
    if (token.isError) return Result.err(token.error);
    while (token.isOk && token.ok.type == TokenType.space) {
      token = _lexer.nextToken();
    }

    if (token.isError) return Result.err(token.error);
    _lexer.keepToken(token.ok);
    return Result.ok(null);
  }

  Result<void, TokenizeError> _skipTokenOfLine() {
    var token = _lexer.nextToken();
    if (token.isError) return Result.err(token.error);
    while (token.isOk &&
        token.ok.type != TokenType.eol &&
        token.ok.type != TokenType.eof) {
      token = _lexer.nextToken();
    }
    if (token.isError) return Result.err(token.error);
    _lexer.keepToken(token.ok);
    return Result.ok(null);
  }

  /// is EOF or OPECODE(END)
  Result<bool, TokenizeError> _isEnd() {
    final token = _lexer.peekToken();
    if (token.isError) return Result.err(token.error);
    if (token.ok.type != TokenType.eof &&
        (String.fromCharCodes(token.ok.runes) != 'END' ||
            token.ok.type != TokenType.op)) {
      return Result.ok(false);
    }

    return Result.ok(true);
  }

  Result<Token?, ParseError> _getLabel() {
    _skipSpaceToken();
    final token = _lexer.nextToken();
    if (token.isError) {
      // skip line
      _skipTokenOfLine();

      final err = token.error;
      return Result.err(ParseError.fromToken(
        '[SYNTAX ERROR] ${err.message}',
        err.token,
      ));
    }
    switch (token.ok.type) {
      case TokenType.label:
        return Result.ok(token.ok);
      default:
        _lexer.keepToken(token.ok);
        return Result.ok(null);
    }
  }

  Result<Token, ParseError> _getOpecode() {
    {
      final result = _skipSpaceToken();
      if (result.isError) {
        final err = result.error;
        return Result.err(ParseError.fromToken(
          '[SYNTAX ERROR] ${err.message}',
          err.token,
        ));
      }
    }

    final token = _lexer.nextToken();
    if (token.isError) {
      // skip line
      _skipTokenOfLine();

      final err = token.error;
      return Result.err(ParseError.fromToken(
        '[SYNTAX ERROR] ${err.message}',
        err.token,
      ));
    }
    switch (token.ok.type) {
      case TokenType.op:
        return Result.ok(token.ok);
      default:
        // skip line
        {
          final result = _skipTokenOfLine();
          if (result.isError) {
            final err = result.error;
            return Result.err(ParseError.fromToken(
              '[SYNTAX ERROR] ${err.message}',
              err.token,
            ));
          }
        }

        return Result.err(ParseError(
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
      if (token.isError) {
        // skip line
        _skipTokenOfLine();

        final err = token.error;
        return Result.err(ParseError.fromToken(
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

          return Result.err(ParseError.fromToken(
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
    return Result.ok(operand);
  }

  /// make block-node
  Result<Statement, ParseError> _nextSubroutine(Statement start, State state) {
    final stmtList = <Statement>[];
    for (final result in nextStatement(state)) {
      if (result.isError) return result;
      stmtList.add(result.ok);
    }

    return Result.ok(Statement.subroutine(start, process: stmtList));
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
        if (end.isError) {
          final err = end.error;

          yield Result.err(ParseError(
            '[SYNTAX ERROR] ${err.message}',
            start: err.token.start,
            end: err.token.end,
            lineStart: err.token.lineStart,
            lineNumber: err.token.lineNumber,
          ));
        }
      }

      final label = _getLabel();
      if (label.isError) yield Result.err(label.error);

      final opecode = _getOpecode();
      if (opecode.isError) yield Result.err(opecode.error);

      final operand = _getOperand();
      if (operand.isError) yield Result.err(operand.error);

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
        yield Result.ok(stmt);
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
      return Result.ok([Code((_) => 0x8100)]);
    case 'NOP':
      return Result.ok([Code((_) => 0)]);
    case '':
    case 'START':
    case 'END':
      return Result.ok([]);
    case 'DC':
      return parseDC(stmt, state);
    case 'DS':
      return parseDS(stmt, state);
    default:
      return parseMacro(stmt as Macro, state);
  }
}