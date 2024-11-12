import '../../charcode/charcode.dart';
import './macro.dart';
import '../ast/ast.dart';
import '../token/token.dart';
import './parser.dart';
import '../typedef.dart';

/// operand pattern: r1,r2 | r,adr(,x)
Result<List<Code>, ParseError> parseGeneral(
  final Node? parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final State state,
) {
  if (operand.length == 2 && operand[1].type == TokenType.gr) {
    return parseR1r2(
      parent,
      label,
      opecode,
      operand,
      state,
    );
  }
  return parseRadrx(
    parent,
    label,
    opecode,
    operand,
    state,
  );
}

/// operand pattern: r,adr(,x)
Result<List<Code>, ParseError> parseRadrx(
  final Node? parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final State state,
) {
  if (operand.length < 2 || operand.length > 3) {
    return Result.err(ParseError(
      '[SYNTAX ERROR] ${String.fromCharCodes(opecode.runes)} wrong number of operands. wants 2 or 3 operands.',
      start: opecode.start,
      end: opecode.end,
      lineStart: opecode.lineStart,
      lineNumber: opecode.lineNumber,
    ));
  }

  final r = operand[0];
  final adr = operand[1];
  final x = operand.length == 3 ? operand[2] : null;

  if (r.type != TokenType.gr) {
    Result.err(ParseError(
      '[SYNTAX ERROR] ${String.fromCharCodes(r.runes)} is not an expected value. value expects between GR0 and GR7.',
      start: r.start,
      end: r.end,
      lineStart: r.lineStart,
      lineNumber: r.lineNumber,
    ));
  }

  if (x != null) {
    if (x.type != TokenType.gr) {
      return Result.err(ParseError(
        '[SYNTAX ERROR] ${String.fromCharCodes(x.runes)} is not an expected value. value expects between GR1 and GR7.',
        start: x.start,
        end: x.end,
        lineStart: x.lineStart,
        lineNumber: x.lineNumber,
      ));
    }

    if (String.fromCharCodes(x.runes) == 'GR0') {
      return Result.err(ParseError(
        '[SYNTAX ERROR] ${String.fromCharCodes(x.runes)} is not an expected value. value expects between GR1 and GR7.',
        start: x.start,
        end: x.end,
        lineStart: x.lineStart,
        lineNumber: x.lineNumber,
      ));
    }
  }

  final baseOpecode = _parseOpecodeRadrx(String.fromCharCodes(opecode.runes));
  final indexR = _registerToNumber(r);
  final indexX = x != null ? _registerToNumber(x) : 0;

  final result = _tokenToCode(parent, adr, state);
  if (result.isError) return result;

  return Result.ok([
    Code((_) => baseOpecode + (indexR << 4) + indexX),
    ...result.ok,
  ]);
}

/// operand pattern: adr(,x)
Result<List<Code>, ParseError> parseAdrx(
  final Node? parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final State state,
) {
  if (operand.length != 1 && operand.length != 2) {
    return Result.err(ParseError(
      '[SYNTAX ERROR] ${String.fromCharCodes(opecode.runes)} wrong number of operands. wants 1 or 2 operands.',
      start: opecode.start,
      end: opecode.end,
      lineStart: opecode.lineStart,
      lineNumber: opecode.lineNumber,
    ));
  }

  final adr = operand[0];
  final x = operand.length == 2 ? operand[1] : null;

  final baseOpecode = _parseOpecodeAdrx(String.fromCharCodes(opecode.runes));
  final indexX = x != null ? _registerToNumber(x) : 0;

  final result = _tokenToCode(parent, adr, state);
  if (result.isError) return result;

  return Result.ok([
    Code((_) => baseOpecode + indexX),
    ...result.ok,
  ]);
}

/// operand pattern: r1,r2
Result<List<Code>, ParseError> parseR1r2(
  final Node? parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final State state,
) {
  if (operand.length != 2) {
    return Result.err(ParseError(
      '[SYNTAX ERROR] ${String.fromCharCodes(opecode.runes)} wrong number of operands. wants 2 operands.',
      start: opecode.start,
      end: opecode.end,
      lineStart: opecode.lineStart,
      lineNumber: opecode.lineNumber,
    ));
  }

  final r1 = operand[0];
  final r2 = operand[1];

  if (r1.type != TokenType.gr) {
    return Result.err(ParseError(
      '[SYNTAX ERROR] ${String.fromCharCodes(r1.runes)} is not an expected value. value expects between GR0 and GR7.',
      start: r1.start,
      end: r1.end,
      lineStart: r1.lineStart,
      lineNumber: r1.lineNumber,
    ));
  }

  if (r2.type != TokenType.gr) {
    return Result.err(ParseError(
      '[SYNTAX ERROR] ${String.fromCharCodes(r2.runes)} is not an expected value. value expects between GR0 and GR7.',
      start: r2.start,
      end: r2.end,
      lineStart: r2.lineStart,
      lineNumber: r2.lineNumber,
    ));
  }

  final baseOpecode = _parseOpecodeR1r2(String.fromCharCodes(opecode.runes));
  final indexR1 = _registerToNumber(r1);
  final indexR2 = _registerToNumber(r2);
  return Result.ok([
    Code((_) => baseOpecode + (indexR1 << 4) + indexR2),
  ]);
}

/// operand pattern: r
Result<List<Code>, ParseError> parseR(
  final Node? parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final State state,
) {
  if (operand.length != 1) {
    return Result.err(ParseError(
      '[SYNTAX ERROR] ${String.fromCharCodes(opecode.runes)} wrong number of operands. wants 1 operands.',
      start: opecode.start,
      end: opecode.end,
      lineStart: opecode.lineStart,
      lineNumber: opecode.lineNumber,
    ));
  }

  final baseOpecode = _parseOpecodeR(String.fromCharCodes(opecode.runes));
  final r = operand[0];

  if (r.type != TokenType.gr) {
    return Result.err(ParseError(
      '[SYNTAX ERROR] ${String.fromCharCodes(r.runes)} is not an expected value. value expects between GR0 and GR7.',
      start: r.start,
      end: r.end,
      lineStart: r.lineStart,
      lineNumber: r.lineNumber,
    ));
  }

  return Result.ok([Code((_) => baseOpecode + (_registerToNumber(r) << 4))]);
}

/// Operand's token to code
///
/// TokenType: string, dec, hex, ref
Result<List<Code>, ParseError> _tokenToCode(
    Node? parent, Token token, State state) {
  switch (token.type) {
    case TokenType.text:
      // `'is''s a small world'` to `is's a small world`
      final runes = token.runes;
      final str = String.fromCharCodes(
        runes.toList().getRange(1, runes.length - 1),
      ).replaceAll("''", "'");

      final code = <Code>[];
      for (final rune in str.runes) {
        code.add(Code((_) => runeAsCode(rune) ?? 0));
      }
      return Result.ok(code);
    case TokenType.dec:
      return Result.ok([
        Code((_) => int.parse(String.fromCharCodes(token.runes))),
      ]);
    case TokenType.hex:
      return Result.ok([
        Code((_) => int.parse(
              String.fromCharCodes(token.runes).replaceFirst('#', '0x'),
            )),
      ]);
    case TokenType.ref:
      final label = String.fromCharCodes(token.runes);
      final ref = state.getLabel(label);
      if (ref == null) {
        return Result.err(ParseError(
          '[EXCEPTION] UNKNOWN LABEL $label',
          start: token.start,
          end: token.end,
          lineStart: token.lineStart,
          lineNumber: token.lineNumber,
        ));
      }

      return Result.ok([
        // TODO
        Code((base) => base + 0),
      ]);
    default:
      return Result.err(ParseError(
        '[SYNTAX ERROR] unexpected token: $token',
        start: token.start,
        end: token.end,
        lineStart: token.lineStart,
        lineNumber: token.lineNumber,
      ));
  }
}

/// OPECODE: DC
Result<List<Code>, ParseError> parseDC(
    Node? parent, List<Token> operand, State state) {
  final code = <Code>[];
  for (final token in operand) {
    final result = _tokenToCode(parent, token, state);
    if (result.isError) return result;
    code.addAll(result.ok);
  }
  return Result.ok(code);
}

Result<List<Code>, ParseError> parseDS(
    Node? parent, List<Token> operand, State state) {
  return Result.ok(List.generate(
      int.parse(String.fromCharCodes(operand[0].runes)),
      (i) => Code((_) => 0)));
}

Result<List<Code>, ParseError> parseMacro(
  final Node? parent,
  final Token? label,
  final Token opecode,
  final List<Token> operand,
  final State state,
) {
  final macro = macroList[String.fromCharCodes(opecode.runes)];
  if (macro == null) {
    return Result.err(ParseError(
      '[SYNTAX ERROR] ${String.fromCharCodes(opecode.runes)} not found.',
      start: opecode.start,
      end: opecode.end,
      lineStart: opecode.lineStart,
      lineNumber: opecode.lineNumber,
    ));
  }

  return macro(
    parent,
    label,
    opecode,
    operand,
    state,
  );
}

int _registerToNumber(Token token) {
  return int.parse(String.fromCharCodes(token.runes).replaceFirst('GR', ''));
}

int _parseOpecodeR1r2(String opecode) {
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

int _parseOpecodeRadrx(final String opecode) {
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

int _parseOpecodeAdrx(final String opecode) {
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
    case 'SVC':
      return 0xf000;
    default:
      return 0;
  }
}

int _parseOpecodeR(final String opecode) {
  switch (opecode) {
    case 'POP':
      return 0x7100;
    default:
      return 0;
  }
}