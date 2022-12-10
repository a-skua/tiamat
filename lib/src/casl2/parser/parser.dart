import '../ast/ast.dart';
import '../lexer/lexer.dart';
import '../token/token.dart';
import './util.dart';
import './state.dart';
import '../typedef.dart';

export './state.dart';

abstract class Parser {
  Result<Node, ParseError> nextNode(Node? parent, State state);
}

class ImplParser implements Parser {
  final Lexer _lexer;

  ImplParser(this._lexer);

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

  bool _isEnd() {
    final token = _lexer.nextToken();
    _lexer.keepToken(token);
    return token.type == TokenType.eof;
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

  Result<Node, ParseError> _makeNode(Node? parent, State state) {
    _skipBlankToken();
    if (_isEnd()) return Result.ok(EndNode(parent));

    final resultLabel = _getLabel(parent);
    if (resultLabel.isError) return Result.err(resultLabel.error);
    final label = resultLabel.ok;

    final resultOpecode = _getOpecode(parent);
    if (resultOpecode.isError) return Result.err(resultOpecode.error);
    final opecode = resultOpecode.ok;

    final resultOperand = _getOperand(parent);
    if (resultOperand.isError) return Result.err(resultOperand.error);
    final operand = resultOperand.ok;

    final stmt = StatementNode(
      parent,
      label,
      opecode,
      operand,
      (parent, label, opecode, operand) =>
          _parse(parent, label, opecode, operand, state),
    );

    if (label != null) {
      state.setLabel(stmt);
    }
    return Result.ok(stmt);
  }

  /// make block-node
  Result<Node, ParseError> _makeBlockNode(Node parent, State state) {
    if (parent.opecode != 'START') {
      return Result.ok(parent);
    }

    final nodeList = [parent];
    while (true) {
      final resultNode = _makeNode(parent, state);
      if (resultNode.isError) return resultNode;
      final node = resultNode.ok;

      parent = node;
      if (node is EndNode) {
        return Result.ok(node);
      }

      nodeList.add(node);

      if (node.opecode == 'END') {
        break;
      }
    }
    return Result.ok(BlockNode(nodeList));
  }

  /// return a parsed result.
  @override
  Result<Node, ParseError> nextNode(Node? parent, State state) {
    final result = _makeNode(parent, state);
    if (result.isError) {
      return result;
    }

    if (result.ok is EndNode) {
      return result;
    }

    return _makeBlockNode(result.ok, State.block(state));
  }
}

/// parser
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
