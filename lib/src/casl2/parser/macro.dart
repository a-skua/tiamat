import '../token/token.dart';
import '../ast/ast.dart';
import './util.dart';
import './state.dart';
import '../typedef.dart';

final macroList = <String,
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
      '[SYNTAX ERROR] ${opecode.runes.toString()} wrong number of operands. wants 2 operands.',
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
      '[SYNTAX ERROR] ${length.runes.toString()} wrong type. wants a number.',
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
      Token.op('LAD'.runes),
      [Token.gr('GR1'.runes), buffer],
      state,
    ),
    parseRadrx(
      parent,
      null,
      Token.op('LAD'.runes),
      [Token.gr('GR2'.runes), length],
      state,
    ),
    parseAdrx(
      parent,
      null,
      Token.op('SVC'.runes),
      [Token.dec('1'.runes)],
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
      '[SYNTAX ERROR] ${opecode.runes.toString()} wrong number of operands. wants 2 operands.',
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
      '[SYNTAX ERROR] ${length.runes.toString()} wrong type. wants a number.',
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
      Token.op('LAD'.runes),
      [Token.gr('GR1'.runes), buffer],
      state,
    ),
    parseRadrx(
      parent,
      null,
      Token.op('LAD'.runes),
      [Token.gr('GR2'.runes), length],
      state,
    ),
    parseAdrx(
      parent,
      null,
      Token.op('SVC'.runes),
      [Token.dec('2'.runes)],
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
      Token.op('PUSH'.runes),
      [
        Token.dec('0'.runes),
        Token.gr('GR1'.runes),
      ],
      state,
    ),
    parseAdrx(
      parent,
      null,
      Token.op('PUSH'.runes),
      [
        Token.dec('0'.runes),
        Token.gr('GR2'.runes),
      ],
      state,
    ),
    parseAdrx(
      parent,
      null,
      Token.op('PUSH'.runes),
      [
        Token.dec('0'.runes),
        Token.gr('GR3'.runes),
      ],
      state,
    ),
    parseAdrx(
      parent,
      null,
      Token.op('PUSH'.runes),
      [
        Token.dec('0'.runes),
        Token.gr('GR4'.runes),
      ],
      state,
    ),
    parseAdrx(
      parent,
      null,
      Token.op('PUSH'.runes),
      [
        Token.dec('0'.runes),
        Token.gr('GR5'.runes),
      ],
      state,
    ),
    parseAdrx(
      parent,
      null,
      Token.op('PUSH'.runes),
      [
        Token.dec('0'.runes),
        Token.gr('GR6'.runes),
      ],
      state,
    ),
    parseAdrx(
      parent,
      null,
      Token.op('PUSH'.runes),
      [
        Token.dec('0'.runes),
        Token.gr('GR7'.runes),
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
      Token.op('POP'.runes),
      [Token.gr('GR7'.runes)],
      state,
    ),
    parseR(
      parent,
      null,
      Token.op('POP'.runes),
      [Token.gr('GR6'.runes)],
      state,
    ),
    parseR(
      parent,
      null,
      Token.op('POP'.runes),
      [Token.gr('GR5'.runes)],
      state,
    ),
    parseR(
      parent,
      null,
      Token.op('POP'.runes),
      [Token.gr('GR4'.runes)],
      state,
    ),
    parseR(
      parent,
      null,
      Token.op('POP'.runes),
      [Token.gr('GR3'.runes)],
      state,
    ),
    parseR(
      parent,
      null,
      Token.op('POP'.runes),
      [Token.gr('GR2'.runes)],
      state,
    ),
    parseR(
      parent,
      null,
      Token.op('POP'.runes),
      [Token.gr('GR1'.runes)],
      state,
    ),
  ].reduce((a, b) {
    if (a.isError) return a;
    if (b.isError) return b;

    a.ok.addAll(b.ok);
    return a;
  });
}