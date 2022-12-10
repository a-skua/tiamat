import '../token/token.dart';
import '../ast/ast.dart';
import './util.dart';
import './state.dart';
import '../typedef.dart';

final macroList = <
    String,
    Result<List<Code>, ParseError> Function(
  Node? parent,
  Token? label,
  Token opecode,
  List<Token> operand,
  State state,
)>{
  'IN': parseIN,
  'OUT': parseOUT,
  'RPUSH': parseRPUSH,
  'RPOP': parseRPOP,
};

Result<List<Code>, ParseError> parseIN(
  final Node? parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final State state,
) {
  if (operand.length != 2) {
    return Result.err(ParseError(
      '[SYNTAX ERROR] ${opecode.runesAsString} wrong number of operands. wants 2 operands.',
      start: opecode.start,
      end: opecode.end,
      lineStart: opecode.lineStart,
      lineNumber: opecode.lineNumber,
    ));
  }

  final buffer = operand[0];
  final length = operand[1];

  if (length.type != TokenType.hex && length.type != TokenType.dec) {
    return Result.err(ParseError(
      '[SYNTAX ERROR] ${length.runesAsString} wrong type. wants a number.',
      start: length.start,
      end: length.end,
      lineStart: length.lineStart,
      lineNumber: length.lineNumber,
    ));
  }

  return [
    parseRadrx(
      parent,
      label,
      Token('LAD'.runes, TokenType.opecode),
      [Token('GR1'.runes, TokenType.gr), buffer],
      state,
    ),
    parseRadrx(
      parent,
      null,
      Token('LAD'.runes, TokenType.opecode),
      [Token('GR2'.runes, TokenType.gr), length],
      state,
    ),
    parseAdrx(
      parent,
      null,
      Token('SVC'.runes, TokenType.opecode),
      [Token('1'.runes, TokenType.dec)],
      state,
    ),
  ].reduce((a, b) {
    if (a.isError) return a;
    if (b.isError) return b;

    a.ok.addAll(b.ok);
    return a;
  });
}

Result<List<Code>, ParseError> parseOUT(
  final Node? parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final State state,
) {
  if (operand.length != 2) {
    return Result.err(ParseError(
      '[SYNTAX ERROR] ${opecode.runesAsString} wrong number of operands. wants 2 operands.',
      start: opecode.start,
      end: opecode.end,
      lineStart: opecode.lineStart,
      lineNumber: opecode.lineNumber,
    ));
  }

  final buffer = operand[0];
  final length = operand[1];

  if (length.type != TokenType.hex && length.type != TokenType.dec) {
    return Result.err(ParseError(
      '[SYNTAX ERROR] ${length.runesAsString} wrong type. wants a number.',
      start: length.start,
      end: length.end,
      lineStart: length.lineStart,
      lineNumber: length.lineNumber,
    ));
  }

  return [
    parseRadrx(
      parent,
      label,
      Token('LAD'.runes, TokenType.opecode),
      [Token('GR1'.runes, TokenType.gr), buffer],
      state,
    ),
    parseRadrx(
      parent,
      null,
      Token('LAD'.runes, TokenType.opecode),
      [Token('GR2'.runes, TokenType.gr), length],
      state,
    ),
    parseAdrx(
      parent,
      null,
      Token('SVC'.runes, TokenType.opecode),
      [Token('2'.runes, TokenType.dec)],
      state,
    ),
  ].reduce((a, b) {
    if (a.isError) return a;
    if (b.isError) return b;

    a.ok.addAll(b.ok);
    return a;
  });
}

Result<List<Code>, ParseError> parseRPUSH(
  final Node? parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final State state,
) {
  return [
    parseAdrx(
      parent,
      label,
      Token('PUSH'.runes, TokenType.opecode),
      [
        Token('0'.runes, TokenType.dec),
        Token('GR1'.runes, TokenType.gr),
      ],
      state,
    ),
    parseAdrx(
      parent,
      null,
      Token('PUSH'.runes, TokenType.opecode),
      [
        Token('0'.runes, TokenType.dec),
        Token('GR2'.runes, TokenType.gr),
      ],
      state,
    ),
    parseAdrx(
      parent,
      null,
      Token('PUSH'.runes, TokenType.opecode),
      [
        Token('0'.runes, TokenType.dec),
        Token('GR3'.runes, TokenType.gr),
      ],
      state,
    ),
    parseAdrx(
      parent,
      null,
      Token('PUSH'.runes, TokenType.opecode),
      [
        Token('0'.runes, TokenType.dec),
        Token('GR4'.runes, TokenType.gr),
      ],
      state,
    ),
    parseAdrx(
      parent,
      null,
      Token('PUSH'.runes, TokenType.opecode),
      [
        Token('0'.runes, TokenType.dec),
        Token('GR5'.runes, TokenType.gr),
      ],
      state,
    ),
    parseAdrx(
      parent,
      null,
      Token('PUSH'.runes, TokenType.opecode),
      [
        Token('0'.runes, TokenType.dec),
        Token('GR6'.runes, TokenType.gr),
      ],
      state,
    ),
    parseAdrx(
      parent,
      null,
      Token('PUSH'.runes, TokenType.opecode),
      [
        Token('0'.runes, TokenType.dec),
        Token('GR7'.runes, TokenType.gr),
      ],
      state,
    ),
  ].reduce((a, b) {
    if (a.isError) return a;
    if (b.isError) return b;

    a.ok.addAll(b.ok);
    return a;
  });
}

Result<List<Code>, ParseError> parseRPOP(
  final Node? parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final State state,
) {
  return [
    parseR(
      parent,
      label,
      Token('POP'.runes, TokenType.opecode),
      [Token('GR7'.runes, TokenType.gr)],
      state,
    ),
    parseR(
      parent,
      null,
      Token('POP'.runes, TokenType.opecode),
      [Token('GR6'.runes, TokenType.gr)],
      state,
    ),
    parseR(
      parent,
      null,
      Token('POP'.runes, TokenType.opecode),
      [Token('GR5'.runes, TokenType.gr)],
      state,
    ),
    parseR(
      parent,
      null,
      Token('POP'.runes, TokenType.opecode),
      [Token('GR4'.runes, TokenType.gr)],
      state,
    ),
    parseR(
      parent,
      null,
      Token('POP'.runes, TokenType.opecode),
      [Token('GR3'.runes, TokenType.gr)],
      state,
    ),
    parseR(
      parent,
      null,
      Token('POP'.runes, TokenType.opecode),
      [Token('GR2'.runes, TokenType.gr)],
      state,
    ),
    parseR(
      parent,
      null,
      Token('POP'.runes, TokenType.opecode),
      [Token('GR1'.runes, TokenType.gr)],
      state,
    ),
  ].reduce((a, b) {
    if (a.isError) return a;
    if (b.isError) return b;

    a.ok.addAll(b.ok);
    return a;
  });
}
