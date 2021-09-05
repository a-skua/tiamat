import '../ast/ast.dart';
import '../lexer/lexer.dart';
import '../token/token.dart';
import './util.dart';
import './macro.dart';

class Parser {
  final List<Token> _tokens;
  var _currentIndex = 0;

  Parser(this._tokens);

  factory Parser.fromLexer(final Lexer lexer) {
    final tokens = <Token>[];
    while (true) {
      final token = lexer.nextToken();
      tokens.add(token);
      if (token.type == TokenType.eof) {
        break;
      }
    }

    return Parser(tokens);
  }

  List<Token> get tokens => List.from(_tokens);

  Program parseProgram() {
    final stmts = <Statement>[];
    final env = Env();
    final errors = <ErrorNode>[];

    Node parent = Root();
    while (true) {
      final node = _nextStmt(parent, env);
      if (node == null) {
        return Program(
          BlockStatement.onlyStatements(stmts),
          env: env,
          errors: errors,
        );
      }

      if (node is ErrorNode) {
        errors.add(node);
        continue;
      }

      final stmt = node as Statement;
      if (stmt.label.isNotEmpty) {
        env.labels[stmt.label] = stmt;
      }
      stmts.add(stmt);
      parent = stmt;
    }
  }

  Node? _nextStmt(Node parent, Env env) {
    var token = _nextToken();

    // FIXME skip empty
    while (token.type == TokenType.eol || token.type == TokenType.comment) {
      token = _nextToken();
    }

    if (token.type == TokenType.eof) {
      return null;
    }

    Token? label;
    Token? opecode;
    var operand = <Token>[];
    while (true) {
      switch (token.type) {
        case TokenType.label:
          label = token;
          break;
        case TokenType.opecode:
          opecode = token;
          break;
        case TokenType.space:
        case TokenType.separation:
        case TokenType.comment:
          break;
        case TokenType.error:
          final error = token as ErrorToken;

          // skip line
          token = _nextToken();
          while (token.type != TokenType.error &&
              token.type != TokenType.eol &&
              token.type != TokenType.eof) {
            token = _nextToken();
          }

          return ErrorNode(
            '[SYNTAX ERROR] ${error.error}',
            start: error.start,
            end: error.end,
            lineStart: error.lineStart,
            lineNumber: error.lineNumber,
          );
        case TokenType.eof:
        case TokenType.eol:
          return parseNode(
            parent,
            label,
            opecode,
            operand,
            env,
            current: token,
          );
        default:
          operand.add(token);
      }
      token = _nextToken();
    }
  }

  Token _nextToken() {
    if (_currentIndex >= _tokens.length) {
      return _tokens.last;
    }
    final token = _tokens[_currentIndex];
    _currentIndex += 1;
    return token;
  }
}

/// parse to node
Node parseNode(
  Node parent,
  Token? label,
  Token? opecode,
  List<Token> operand,
  Env env, {
  required Token current,
}) {
  if (opecode == null) {
    return ErrorNode(
      '[SYNTAX ERROR] opecode not found.',
      start: current.end,
      end: current.end + 1,
      lineStart: current.lineStart,
      lineNumber: current.lineNumber,
    );
  }

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
      return parseGeneralNode(
        parent,
        label,
        opecode,
        operand,
        env,
      );
    case 'ST':
    case 'LAD':
    case 'SLA':
    case 'SRA':
    case 'SLL':
    case 'SRL':
      return parseRadrxNode(
        parent,
        label,
        opecode,
        operand,
        env,
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
      return parseAdrxNode(
        parent,
        label,
        opecode,
        operand,
        env,
      );
    case 'POP':
      // TODO error handling!
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: [
          LiteralCode(
            0x7100 + (registerToNumber(operand[0]) << 4),
          )
        ],
      );
    case 'RET':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: [LiteralCode(0x8100)],
      );
    case 'START':
    case 'END':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
      );
    case 'DC':
      // TODO error handling!
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseDC(operand, env),
      );
    case 'DS':
      // TODO error handling!
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseDS(operand, env),
      );
    default:
      return parseMacro(
        parent,
        label,
        opecode,
        operand,
        env,
      );
  }
}

Node parseMacro(
  final Node parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final Env env,
) {
  final macro = macros[opecode.runesAsString];
  if (macro == null) {
    return ErrorNode(
      '[SYNTAX ERROR] ${opecode.runesAsString} not found.',
      start: opecode.start,
      end: opecode.end,
      lineStart: opecode.lineStart,
      lineNumber: opecode.lineNumber,
    );
  }

  return macro(
    parent,
    label,
    opecode,
    operand,
    env,
  );
}

List<Code> _parseDC(List<Token> operand, Env env) {
  final result = <Code>[];
  for (final token in operand) {
    result.addAll(tokenToCode(token, env));
  }
  return result;
}

List<Code> _parseDS(List<Token> operand, Env env) {
  return List.generate(
      int.parse(operand[0].runesAsString), (i) => LiteralCode(0));
}
