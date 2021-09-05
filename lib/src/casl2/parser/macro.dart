import '../token/token.dart';
import '../ast/ast.dart';
import './util.dart';

final macros = <
    String,
    Node Function(
  Node parent,
  Token? label,
  Token opecode,
  List<Token> operand,
  Env env,
)>{
  'IN': parseIN,
  'OUT': parseOUT,
  'RPUSH': parseRPUSH,
  'RPOP': parseRPOP,
};

Node parseIN(
  final Node parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final Env env,
) {
  if (operand.length != 2) {
    return ErrorNode(
      '[SYNTAX ERROR] ${opecode.runesAsString} wrong number of operands. wants 2 operands.',
      start: opecode.start,
      end: opecode.end,
      lineStart: opecode.lineStart,
      lineNumber: opecode.lineNumber,
    );
  }

  final buffer = operand[0];
  final length = operand[1];

  if (length.type != TokenType.hex && length.type != TokenType.dec) {
    return ErrorNode(
      '[SYNTAX ERROR] ${length.runesAsString} wrong type. wants a number.',
      start: length.start,
      end: length.end,
      lineStart: length.lineStart,
      lineNumber: length.lineNumber,
    );
  }

  final step1 = parseRadrxNode(
    parent,
    label,
    Token('LAD'.runes, TokenType.opecode),
    [Token('GR1'.runes, TokenType.gr), buffer],
    env,
  ) as Statement;
  final step2 = parseRadrxNode(
    step1,
    null,
    Token('LAD'.runes, TokenType.opecode),
    [Token('GR2'.runes, TokenType.gr), length],
    env,
  ) as Statement;
  final step3 = parseAdrxNode(
    step2,
    null,
    Token('SVC'.runes, TokenType.opecode),
    [Token('1'.runes, TokenType.dec)],
    env,
  ) as Statement;

  return BlockStatement(
    [
      step1,
      step2,
      step3,
    ],
    parent: parent,
    opecode: opecode,
    operand: operand,
  );
}

Node parseOUT(
  final Node parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final Env env,
) {
  if (operand.length != 2) {
    return ErrorNode(
      '[SYNTAX ERROR] ${opecode.runesAsString} wrong number of operands. wants 2 operands.',
      start: opecode.start,
      end: opecode.end,
      lineStart: opecode.lineStart,
      lineNumber: opecode.lineNumber,
    );
  }

  final buffer = operand[0];
  final length = operand[1];

  if (length.type != TokenType.hex && length.type != TokenType.dec) {
    return ErrorNode(
      '[SYNTAX ERROR] ${length.runesAsString} wrong type. wants a number.',
      start: length.start,
      end: length.end,
      lineStart: length.lineStart,
      lineNumber: length.lineNumber,
    );
  }

  final step1 = parseRadrxNode(
    parent,
    label,
    Token('LAD'.runes, TokenType.opecode),
    [Token('GR1'.runes, TokenType.gr), buffer],
    env,
  ) as Statement;
  final step2 = parseRadrxNode(
    step1,
    null,
    Token('LAD'.runes, TokenType.opecode),
    [Token('GR2'.runes, TokenType.gr), length],
    env,
  ) as Statement;
  final step3 = parseAdrxNode(
    step2,
    null,
    Token('SVC'.runes, TokenType.opecode),
    [Token('2'.runes, TokenType.dec)],
    env,
  ) as Statement;

  return BlockStatement(
    [
      step1,
      step2,
      step3,
    ],
    parent: parent,
    opecode: opecode,
    operand: operand,
  );
}

Node parseRPUSH(
  final Node parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final Env env,
) {
  final step1 = parseAdrxNode(
    parent,
    label,
    Token('PUSH'.runes, TokenType.opecode),
    [
      Token('0'.runes, TokenType.dec),
      Token('GR1'.runes, TokenType.gr),
    ],
    env,
  ) as Statement;
  final step2 = parseAdrxNode(
    step1,
    null,
    Token('PUSH'.runes, TokenType.opecode),
    [
      Token('0'.runes, TokenType.dec),
      Token('GR2'.runes, TokenType.gr),
    ],
    env,
  ) as Statement;
  final step3 = parseAdrxNode(
    step2,
    null,
    Token('PUSH'.runes, TokenType.opecode),
    [
      Token('0'.runes, TokenType.dec),
      Token('GR3'.runes, TokenType.gr),
    ],
    env,
  ) as Statement;
  final step4 = parseAdrxNode(
    step3,
    null,
    Token('PUSH'.runes, TokenType.opecode),
    [
      Token('0'.runes, TokenType.dec),
      Token('GR4'.runes, TokenType.gr),
    ],
    env,
  ) as Statement;
  final step5 = parseAdrxNode(
    step4,
    null,
    Token('PUSH'.runes, TokenType.opecode),
    [
      Token('0'.runes, TokenType.dec),
      Token('GR5'.runes, TokenType.gr),
    ],
    env,
  ) as Statement;
  final step6 = parseAdrxNode(
    step5,
    null,
    Token('PUSH'.runes, TokenType.opecode),
    [
      Token('0'.runes, TokenType.dec),
      Token('GR6'.runes, TokenType.gr),
    ],
    env,
  ) as Statement;
  final step7 = parseAdrxNode(
    step6,
    null,
    Token('PUSH'.runes, TokenType.opecode),
    [
      Token('0'.runes, TokenType.dec),
      Token('GR7'.runes, TokenType.gr),
    ],
    env,
  ) as Statement;

  return BlockStatement(
    [
      step1,
      step2,
      step3,
      step4,
      step5,
      step6,
      step7,
    ],
    parent: parent,
    opecode: opecode,
    operand: operand,
  );
}

Node parseRPOP(
  final Node parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final Env env,
) {
  final step1 = parseRNode(
    parent,
    label,
    Token('POP'.runes, TokenType.opecode),
    [Token('GR7'.runes, TokenType.gr)],
    env,
  ) as Statement;
  final step2 = parseRNode(
    step1,
    null,
    Token('POP'.runes, TokenType.opecode),
    [Token('GR6'.runes, TokenType.gr)],
    env,
  ) as Statement;
  final step3 = parseRNode(
    step2,
    null,
    Token('POP'.runes, TokenType.opecode),
    [Token('GR5'.runes, TokenType.gr)],
    env,
  ) as Statement;
  final step4 = parseRNode(
    step3,
    null,
    Token('POP'.runes, TokenType.opecode),
    [Token('GR4'.runes, TokenType.gr)],
    env,
  ) as Statement;
  final step5 = parseRNode(
    step4,
    null,
    Token('POP'.runes, TokenType.opecode),
    [Token('GR3'.runes, TokenType.gr)],
    env,
  ) as Statement;
  final step6 = parseRNode(
    step5,
    null,
    Token('POP'.runes, TokenType.opecode),
    [Token('GR2'.runes, TokenType.gr)],
    env,
  ) as Statement;
  final step7 = parseRNode(
    step6,
    null,
    Token('POP'.runes, TokenType.opecode),
    [Token('GR1'.runes, TokenType.gr)],
    env,
  ) as Statement;

  return BlockStatement(
    [
      step1,
      step2,
      step3,
      step4,
      step5,
      step6,
      step7,
    ],
    parent: parent,
    opecode: opecode,
    operand: operand,
  );
}
