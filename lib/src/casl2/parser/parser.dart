import '../ast/ast.dart';
import '../lexer/lexer.dart';
import '../token/token.dart';
import './util.dart';
import './state.dart';
import '../typedef.dart';
export './state.dart';

/// Parser of CASL2
abstract class Parser {
  Iterable<Result<StatementNode, ParseError>> nextStatement(State state);

  /// Create a parser instance.
  factory Parser(Lexer lexer) => _Parser(lexer);
}

class _Parser implements Parser {
  final Lexer _lexer;

  _Parser(this._lexer);

  void _skipBlankToken() {
    var token = _lexer.nextToken();
    while (token.type == TokenType.space ||
        token.type == TokenType.eol ||
        token.type == TokenType.comment) {
      token = _lexer.nextToken();
    }
    _lexer.keepToken(token);
  }

  void _skipSpaceToken() {
    var token = _lexer.nextToken();
    while (token.type == TokenType.space) {
      token = _lexer.nextToken();
    }
    _lexer.keepToken(token);
  }

  void _skipTokenOfLine() {
    var token = _lexer.nextToken();
    while (token.type != TokenType.error &&
        token.type != TokenType.eol &&
        token.type != TokenType.eof) {
      token = _lexer.nextToken();
    }
    _lexer.keepToken(token);
  }

  /// is EOF or OPECODE(END)
  bool _isEnd() {
    final token = _lexer.peekToken();
    if (token.type != TokenType.eof &&
        (token.runesAsString != 'END' || token.type != TokenType.opecode)) {
      return false;
    }

    _lexer.nextToken();
    return true;
  }

  Result<Token?, ParseError> _getLabel(Node? parent) {
    _skipSpaceToken();
    final token = _lexer.nextToken();
    switch (token.type) {
      case TokenType.label:
        return Result.ok(token);
      case TokenType.error:
        final error = token as ErrorToken;

        // skip line
        _skipTokenOfLine();

        return Result.err(ParseError(
          '[SYNTAX ERROR] ${error.error}',
          start: error.start,
          end: error.end,
          lineStart: error.lineStart,
          lineNumber: error.lineNumber,
        ));
      default:
        _lexer.keepToken(token);
        return Result.ok(null);
    }
  }

  Result<Token, ParseError> _getOpecode(Node? parent) {
    _skipSpaceToken();
    final token = _lexer.nextToken();
    switch (token.type) {
      case TokenType.opecode:
        return Result.ok(token);
      case TokenType.error:
        final error = token as ErrorToken;

        // skip line
        _skipTokenOfLine();

        return Result.err(ParseError(
          '[SYNTAX ERROR] ${error.error}',
          start: error.start,
          end: error.end,
          lineStart: error.lineStart,
          lineNumber: error.lineNumber,
        ));
      default:
        // skip line
        _skipTokenOfLine();

        return Result.err(ParseError(
          '[SYNTAX ERROR] Unexpected token: $token',
          start: token.start,
          end: token.end,
          lineStart: token.lineStart,
          lineNumber: token.lineNumber,
        ));
    }
  }

  Result<List<Token>, ParseError> _getOperand(Node? parent) {
    final operand = <Token>[];

    loop:
    while (true) {
      final token = _lexer.nextToken();
      switch (token.type) {
        case TokenType.space:
        case TokenType.separation:
        case TokenType.comment:
          break;
        case TokenType.label:
        case TokenType.opecode:
          // skip line
          _skipTokenOfLine();

          return Result.err(ParseError(
            '[SYNTAX ERROR] Unexpected token: $token',
            start: token.start,
            end: token.end,
            lineStart: token.lineStart,
            lineNumber: token.lineNumber,
          ));
        case TokenType.error:
          final error = token as ErrorToken;

          // skip line
          _skipTokenOfLine();

          return Result.err(ParseError(
            '[SYNTAX ERROR] ${error.error}',
            start: error.start,
            end: error.end,
            lineStart: error.lineStart,
            lineNumber: error.lineNumber,
          ));
        case TokenType.eof:
        case TokenType.eol:
          break loop;
        default:
          operand.add(token);
      }
    }
    return Result.ok(operand);
  }

  /// make block-node
  Result<StatementNode, ParseError> _nextSubroutine(
      StatementNode start, State state) {
    final stmtList = <StatementNode>[];
    for (final result in nextStatement(state)) {
      if (result.isError) return result;
      stmtList.add(result.ok);
    }

    return Result.ok(StatementNode.subroutine(start, process: stmtList));
  }

  /// return a parsed result.
  ///
  /// EOF or OPECODE(END) is true, finish parsing.
  @override
  Iterable<Result<StatementNode, ParseError>> nextStatement(State state) sync* {
    StatementNode? parent;
    while (true) {
      _skipBlankToken();
      if (_isEnd()) return;

      final label = _getLabel(parent);
      if (label.isError) yield Result.err(label.error);

      final opecode = _getOpecode(parent);
      if (opecode.isError) yield Result.err(opecode.error);

      final operand = _getOperand(parent);
      if (operand.isError) yield Result.err(operand.error);

      final stmt = StatementNode(
        opecode.ok,
        label: label.ok,
        operand: operand.ok,
      );

      if (label.ok != null) {
        state.setLabel(stmt);
      }

      parent = stmt;
      if (stmt.opecode.runesAsString == 'START') {
        yield _nextSubroutine(stmt, state);
      } else {
        yield Result.ok(stmt);
      }
    }
  }
}

/// TODO parser
Result<List<Code>, ParseError> _parse(Node? parent, Token? label, Token opecode,
    List<Token> operand, State state) {
  switch (opecode.runesAsString) {
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
      return parseGeneral(
        parent,
        label,
        opecode,
        operand,
        state,
      );
    case 'ST':
    case 'LAD':
    case 'SLA':
    case 'SRA':
    case 'SLL':
    case 'SRL':
      return parseRadrx(
        parent,
        label,
        opecode,
        operand,
        state,
      );
    case 'JMI':
    case 'JNZ':
    case 'JZE':
    case 'JUMP':
    case 'JPL':
    case 'JOV':
    case 'PUSH':
    case 'CALL':
    case 'SVC':
      return parseAdrx(
        parent,
        label,
        opecode,
        operand,
        state,
      );
    case 'POP':
      return parseR(
        parent,
        label,
        opecode,
        operand,
        state,
      );
    case 'RET':
      return Result.ok([Code((_) => 0x8100)]);
    case 'NOP':
      return Result.ok([Code((_) => 0)]);
    case '':
    case 'START':
    case 'END':
      return Result.ok([]);
    case 'DC':
      return parseDC(parent, operand, state);
    case 'DS':
      return parseDS(parent, operand, state);
    default:
      return parseMacro(
        parent,
        label,
        opecode,
        operand,
        state,
      );
  }
}