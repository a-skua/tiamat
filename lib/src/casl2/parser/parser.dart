import '../../charcode/charcode.dart';
import '../ast/ast.dart';
import '../lexer/lexer.dart';
import '../token/token.dart';

class Parser {
  final Lexer _lexer;

  Parser(this._lexer);

  Program parseProgram() {
    final stmts = <Statement>[];
    final env = Env();
    final errors = <ErrorNode>[];

    Node parent = Root();
    while (true) {
      final node = _nextStmt(parent, env);
      if (node == null) {
        return Program(
          stmts,
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
            opecode,
            operand,
            env,
            current: token,
          );
        default:
          operand.add(token);
      }
      token = _lexer.nextToken();
    }
  }
}

/// operand pattern: r1,r2 | r,adr(,x)
///
/// [r1r2] and [radrx] is opecode.
/// use [secondOpecode] when pattern is r,adr(,x)
Node parseGeneralNode(
  final Node parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final Env env,
) {
  if (operand.length == 2 && operand[1].type == TokenType.gr) {
    return parseR1r2Node(
      parent,
      label,
      opecode,
      operand,
      env,
    );
  }

  return parseRadrxNode(
    parent,
    label,
    opecode,
    operand,
    env,
  );
}

Node parseRadrxNode(
  final Node parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final Env env,
) {
  if (operand.isEmpty) {
    return ErrorNode(
      '[SYNTAX ERROR] ${opecode.runesAsString} has required operands.',
      start: opecode.start,
      end: opecode.end,
      lineStart: opecode.lineStart,
      lineNumber: opecode.lineNumber,
    );
  }

  if (operand.length < 2 || operand.length > 3) {
    return ErrorNode(
      '[SYNTAX ERROR] ${opecode.runesAsString} wrong number of operands. wants 2 or 3 operands.',
      start: opecode.start,
      end: opecode.end,
      lineStart: opecode.lineStart,
      lineNumber: opecode.lineNumber,
    );
  }

  if (operand[0].type != TokenType.gr) {
    final r = operand[0];
    return ErrorNode(
      '[SYNTAX ERROR] ${r.runesAsString} is not an expected value. value expects between GR0 and GR7.',
      start: r.start,
      end: r.end,
      lineStart: r.lineStart,
      lineNumber: r.lineNumber,
    );
  }

  if (operand.length == 3 && operand[2].type != TokenType.gr) {
    final x = operand[2];
    return ErrorNode(
      '[SYNTAX ERROR] ${x.runesAsString} is not an expected value. value expects between GR1 and GR7.',
      start: x.start,
      end: x.end,
      lineStart: x.lineStart,
      lineNumber: x.lineNumber,
    );
  }

  if (operand.length == 3 && operand[2].runesAsString == 'GR0') {
    final x = operand[2];
    return ErrorNode(
      '[SYNTAX ERROR] ${x.runesAsString} is not an expected value. value expects between GR1 and GR7.',
      start: x.start,
      end: x.end,
      lineStart: x.lineStart,
      lineNumber: x.lineNumber,
    );
  }

  final r = operand[0];
  final adr = operand[1];
  final x = operand.length == 3 ? operand[2] : Token('GR0'.runes, TokenType.gr);

  final baseOpecode = radrxOpecode(opecode.runesAsString);
  final indexR = parseRegToInt(r);
  final indexX = parseRegToInt(x);
  return Statement(
    parent,
    opecode,
    operand,
    label: label,
    code: [
      LiteralCode(baseOpecode + (indexR << 4) + indexX),
      ...tokenToCode(adr, env),
    ],
  );
}

Node parseR1r2Node(
  final Node parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final Env env,
) {
  if (operand.isEmpty) {
    return ErrorNode(
      '[SYNTAX ERROR] ${opecode.runesAsString} has required operands.',
      start: opecode.start,
      end: opecode.end,
      lineStart: opecode.lineStart,
      lineNumber: opecode.lineNumber,
    );
  }
  if (operand.length != 2) {
    return ErrorNode(
      '[SYNTAX ERROR] ${opecode.runesAsString} wrong number of operands. wants 2 operands.',
      start: opecode.start,
      end: opecode.end,
      lineStart: opecode.lineStart,
      lineNumber: opecode.lineNumber,
    );
  }
  final r1 = operand[0];
  final r2 = operand[1];

  if (r1.type != TokenType.gr) {
    return ErrorNode(
      '[SYNTAX ERROR] ${r1.runesAsString} is not an expected value. value expects between GR0 and GR7.',
      start: r1.start,
      end: r1.end,
      lineStart: r1.lineStart,
      lineNumber: r1.lineNumber,
    );
  }

  if (r2.type != TokenType.gr) {
    return ErrorNode(
      '[SYNTAX ERROR] ${r2.runesAsString} is not an expected value. value expects between GR0 and GR7.',
      start: r2.start,
      end: r2.end,
      lineStart: r2.lineStart,
      lineNumber: r2.lineNumber,
    );
  }

  final baseOpecode = r1r2opecode(opecode.runesAsString);
  final indexR1 = parseRegToInt(r1);
  final indexR2 = parseRegToInt(r2);
  // expect r1,r2
  return Statement(
    parent,
    opecode,
    operand,
    label: label,
    code: [
      LiteralCode(baseOpecode + (indexR1 << 4) + indexR2),
    ],
  );
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
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: _parseAdrX(adrxOpecode(opecode.runesAsString), operand, env),
      );
    case 'POP':
      return Statement(
        parent,
        opecode,
        operand,
        label: label,
        code: [
          LiteralCode(
            0x7100 + (parseRegToInt(operand[0]) << 4), // TODO error handling!
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

List<Code> _parseAdrX(int opecode, List<Token> operand, Env env) {
  final result = <Code>[];
  if (operand.length != 1 && operand.length != 2) {
    // TODO error!
    return result;
  }

  if (operand.length == 2 && operand[1].type == TokenType.gr) {
    result.add(LiteralCode(opecode + parseRegToInt(operand[1])));
  } else {
    result.add(LiteralCode(opecode));
  }

  result.addAll(tokenToCode(operand[0], env));

  return result;
}

List<Code> _parseDC(List<Token> operand, Env env) {
  final result = <Code>[];
  for (final token in operand) {
    result.addAll(tokenToCode(token, env));
  }
  return result;
}

/// Operand's token to code
List<Code> tokenToCode(Token token, Env env) {
  switch (token.type) {
    case TokenType.string:
      // `'is''s a small world'` to `is's a small world`
      final runes = token.runes;
      final str = String.fromCharCodes(
        runes.getRange(1, runes.length - 1),
      ).replaceAll("''", "'");

      final code = <Code>[];
      for (final rune in str.runes) {
        code.add(LiteralCode(runeAsCode(rune) ?? 0));
      }
      return code;
    case TokenType.dec:
      return [
        LiteralCode(int.parse(token.runesAsString)),
      ];
    case TokenType.hex:
      return [
        LiteralCode(int.parse(
          token.runesAsString.replaceFirst('#', '0x'),
        )),
      ];
    case TokenType.ident:
      return [
        LabelCode(token.runesAsString, 0, env),
      ];
    default:
      // TODO error!
      return [];
  }
}

int parseRegToInt(Token token) {
  return int.parse(token.runesAsString.replaceFirst('GR', ''));
}

int r1r2opecode(String opecode) {
  switch (opecode) {
    case 'LD':
      return 0x1400;
    case 'ADDA':
      return 0x2400;
    case 'SUBA':
      return 0x2500;
    case 'ADDL':
      return 0x2600;
    case 'SUBL':
      return 0x2700;
    case 'AND':
      return 0x3400;
    case 'OR':
      return 0x3500;
    case 'XOR':
      return 0x3600;
    case 'CPA':
      return 0x4400;
    case 'CPL':
      return 0x4500;
    default:
      return 0;
  }
}

int radrxOpecode(String opecode) {
  switch (opecode) {
    case 'LD':
      return 0x1000;
    case 'ST':
      return 0x1100;
    case 'LAD':
      return 0x1200;
    case 'ADDA':
      return 0x2000;
    case 'SUBA':
      return 0x2100;
    case 'ADDL':
      return 0x2200;
    case 'SUBL':
      return 0x2300;
    case 'AND':
      return 0x3000;
    case 'OR':
      return 0x3100;
    case 'XOR':
      return 0x3200;
    case 'CPA':
      return 0x4000;
    case 'CPL':
      return 0x4100;
    case 'SLA':
      return 0x5000;
    case 'SRA':
      return 0x5100;
    case 'SLL':
      return 0x5200;
    case 'SRL':
      return 0x5300;
    default:
      return 0;
  }
}

int adrxOpecode(String opecode) {
  switch (opecode) {
    case 'JMI':
      return 0x6100;
    case 'JNZ':
      return 0x6200;
    case 'JZE':
      return 0x6300;
    case 'JUMP':
      return 0x6400;
    case 'JPL':
      return 0x6500;
    case 'JOV':
      return 0x6600;
    case 'PUSH':
      return 0x7000;
    case 'CALL':
      return 0x8000;
    default:
      return 0;
  }
}
