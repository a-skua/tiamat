import '../../charcode/charcode.dart';
import '../ast/ast.dart';
import '../lexer/lexer.dart';
import '../token/token.dart';

class Parser {
  final Lexer _lexer;

  Parser(this._lexer);

  Program parseProgram() {
    final stmts = <Node>[];

    final env = Env();
    Node node = Root();
    while (true) {
      final stmt = _nextStmt(node, env);
      if (stmt == null) {
        return Program(stmts, env);
      } else {
        env.labels[(stmt as Statement).label] = stmt; // TODO
      }
      stmts.add(stmt);
      node = stmt;
    }
  }

  Node? _nextStmt(Node parent, Env env) {
    var token = _lexer.nextToken();

    // FIXME skip empty
    while (token.type == TokenType.eol || token.type == TokenType.comment) {
      token = _lexer.nextToken();
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
        case TokenType.comment:
          break;
        case TokenType.eof:
        case TokenType.eol:
          return parseNode(
            parent,
            label,
            opecode as Token, // TODO error handling!
            operand,
            env,
          );
        default:
          operand.add(token);
      }
      token = _lexer.nextToken();
    }
  }
}

Node parseNode(
  Node parent,
  Token? label,
  Token opecode,
  List<Token> operand,
  Env env,
) {
  switch (opecode.runesAsString) {
    case 'LD':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: operand[1].type == TokenType.gr // TODO error handling!
            ? _parseR1R2(0x1400, operand, env)
            : _parseRAdxX(0x1000, operand, env),
      );
    case 'ST':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseRAdxX(0x1100, operand, env),
      );
    case 'LAD':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseRAdxX(0x1200, operand, env),
      );
    case 'ADDA':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: operand[1].type == TokenType.gr // TODO error handling!
            ? _parseR1R2(0x2400, operand, env)
            : _parseRAdxX(0x2000, operand, env),
      );
    case 'SUBA':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: operand[1].type == TokenType.gr // TODO error handling!
            ? _parseR1R2(0x2500, operand, env)
            : _parseRAdxX(0x2100, operand, env),
      );
    case 'ADDL':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: operand[1].type == TokenType.gr // TODO error handling!
            ? _parseR1R2(0x2600, operand, env)
            : _parseRAdxX(0x2200, operand, env),
      );
    case 'SUBL':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: operand[1].type == TokenType.gr // TODO error handling!
            ? _parseR1R2(0x2700, operand, env)
            : _parseRAdxX(0x2300, operand, env),
      );
    case 'AND':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: operand[1].type == TokenType.gr // TODO error handling!
            ? _parseR1R2(0x3400, operand, env)
            : _parseRAdxX(0x3000, operand, env),
      );
    case 'OR':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: operand[1].type == TokenType.gr // TODO error handling!
            ? _parseR1R2(0x3500, operand, env)
            : _parseRAdxX(0x3100, operand, env),
      );
    case 'XOR':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: operand[1].type == TokenType.gr // TODO error handling!
            ? _parseR1R2(0x3600, operand, env)
            : _parseRAdxX(0x3200, operand, env),
      );
    case 'CPA':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: operand[1].type == TokenType.gr // TODO error handling!
            ? _parseR1R2(0x4400, operand, env)
            : _parseRAdxX(0x4000, operand, env),
      );
    case 'CPL':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: operand[1].type == TokenType.gr // TODO error handling!
            ? _parseR1R2(0x4500, operand, env)
            : _parseRAdxX(0x4100, operand, env),
      );
    case 'SLA':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseRAdxX(0x5000, operand, env),
      );
    case 'SRA':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseRAdxX(0x5100, operand, env),
      );
    case 'SLL':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseRAdxX(0x5200, operand, env),
      );
    case 'SRL':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseRAdxX(0x5300, operand, env),
      );
    case 'JMI':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseAdrX(0x6100, operand, env),
      );
    case 'JNZ':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseAdrX(0x6200, operand, env),
      );
    case 'JZE':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseAdrX(0x6300, operand, env),
      );
    case 'JUMP':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseAdrX(0x6400, operand, env),
      );
    case 'JPL':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseAdrX(0x6500, operand, env),
      );
    case 'JOV':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseAdrX(0x6600, operand, env),
      );
    case 'PUSH':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseAdrX(0x7000, operand, env),
      );
    case 'POP':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: [
          LiteralCode(
              0x7100 + (parseGR2Int(operand[0]) << 4)), // TODO error handling!
        ],
      );
    case 'CALL':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseAdrX(0x8000, operand, env),
      );
    case 'RET':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: [
          LiteralCode(0x8100),
        ],
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
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseDC(operand, env),
      );
    default:
      // TODO macro or error!
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
      );
  }
}

List<Code> _parseRAdxX(
  final int opecode,
  final List<Token> operand,
  final Env env,
) {
  final result = <Code>[];

  if (operand.length != 2 && operand.length != 3) {
    // TODO error!
    return result;
  }

  if (operand.length == 3 && operand[2].type == TokenType.gr) {
    final r = parseGR2Int(operand[0]);
    final x = parseGR2Int(operand[2]);
    result.add(LiteralCode(opecode + (r << 4) + x));
  }
  result.add(tokenToCode(operand[1], env));

  return result;
}

List<Code> _parseR1R2(
  final int opecode,
  final List<Token> operand,
  final Env env,
) {
  final result = <Code>[];
  if (operand.length != 2) {
    // TODO error!
    return result;
  }

  final r1 = parseGR2Int(operand[0]);
  final r2 = parseGR2Int(operand[1]);
  result.add(LiteralCode(opecode + (r1 << 4) + r2));

  return result;
}

List<Code> _parseAdrX(int opecode, List<Token> operand, Env env) {
  final result = <Code>[];
  if (operand.length != 1 && operand.length != 2) {
    // TODO error!
    return result;
  }

  if (operand.length == 2 && operand[1].type == TokenType.gr) {
    result.add(LiteralCode(opecode + parseGR2Int(operand[1])));
  } else {
    result.add(LiteralCode(opecode));
  }

  result.add(tokenToCode(operand[0], env));

  return result;
}

List<Code> _parseDC(List<Token> operand, Env env) {
  final result = <Code>[];
  for (final token in operand) {
    switch (token.type) {
      case TokenType.string:
        final runes = token.runes;
        // `'is''s a small world'` to `is's a small world`
        final str = String.fromCharCodes(runes.getRange(1, runes.length - 1))
            .replaceAll("''", "'");
        for (final rune in str.runes) {
          result.add(LiteralCode(runeAsCode(rune) ?? 0));
        }
        break;
      default:
        result.add(tokenToCode(token, env));
    }
  }
  return result;
}

Code tokenToCode(Token token, Env env) {
  switch (token.type) {
    case TokenType.dec:
      return LiteralCode(int.parse(token.runesAsString));
    case TokenType.hex:
      return LiteralCode(
          int.parse(token.runesAsString.replaceFirst('#', '0x')));
    case TokenType.ident:
      return LabelCode(token.runesAsString, 0, env);
    default:
      // TODO error!
      return LiteralCode(0);
  }
}

int parseGR2Int(Token token) {
  return int.parse(token.runesAsString.replaceFirst('GR', ''));
}
