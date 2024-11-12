import '../../charcode/charcode.dart';
import './macro.dart';
import '../ast/ast.dart';
import '../token/token.dart';
import './parser.dart';
import '../typedef.dart';

final _gr0 = Token.gr('GR0'.runes);

/// operand pattern: r1,r2 | r,adr(,x)
Result<List<Code>, ParseError> parseGeneral(Statement stmt, State state) {
  if (stmt.operand.length == 2 && stmt.operand[1].type == TokenType.gr) {
    return parseR1r2(stmt, state);
  }
  return parseRadrx(stmt, state);
}

/// operand pattern: r,adr(,x)
Result<List<Code>, ParseError> parseRadrx(Statement stmt, State state) {
  switch (stmt.operand) {
    case [final r, final adr]:
      if (r.type != TokenType.gr) {
        return Result.err(ParseError.fromToken(
          '[SYNTAX ERROR] ${String.fromCharCodes(r.runes)} is not an expected value. value expects between GR0 and GR7.',
          r,
        ));
      }

      return _parseRadrx(stmt.opecode, r, adr, _gr0, state);
    case [final r, final adr, final x]:
      if (r.type != TokenType.gr) {
        return Result.err(ParseError.fromToken(
          '[SYNTAX ERROR] ${String.fromCharCodes(r.runes)} is not an expected value. value expects between GR0 and GR7.',
          r,
        ));
      }
      if (x.type != TokenType.gr) {
        return Result.err(ParseError.fromToken(
          '[SYNTAX ERROR] ${String.fromCharCodes(x.runes)} is not an expected value. value expects between GR1 and GR7.',
          x,
        ));
      }
      if (String.fromCharCodes(x.runes) == 'GR0') {
        return Result.err(ParseError.fromToken(
          '[SYNTAX ERROR] ${String.fromCharCodes(x.runes)} is not an expected value. value expects between GR1 and GR7.',
          x,
        ));
      }

      return _parseRadrx(stmt.opecode, r, adr, x, state);
    default:
      return Result.err(ParseError.fromToken(
        '[SYNTAX ERROR] ${String.fromCharCodes(stmt.opecode.runes)} wrong number of operands. wants 2 or 3 operands.',
        stmt.opecode,
      ));
  }
}

Result<List<Code>, ParseError> _parseRadrx(
  Token op,
  Token r,
  Token adr,
  Token x,
  State state,
) {
  final baseOpecode = _parseOpecodeRadrx(String.fromCharCodes(op.runes));
  final indexR = _registerToNumber(r);
  final indexX = _registerToNumber(x);

  final result = _tokenToCode(adr, state);
  if (result.isError) return result;

  return Result.ok([
    Code((_) => baseOpecode + (indexR << 4) + indexX),
    ...result.ok,
  ]);
}

/// operand pattern: adr(,x)
Result<List<Code>, ParseError> parseAdrx(Statement stmt, State state) {
  switch (stmt.operand) {
    case [final adr]:
      return _parseAdrx(stmt.opecode, adr, _gr0, state);
    case [final adr, final x]:
      return _parseAdrx(stmt.opecode, adr, x, state);
    default:
      return Result.err(ParseError.fromToken(
        '[SYNTAX ERROR] ${String.fromCharCodes(stmt.opecode.runes)} wrong number of operands. wants 1 or 2 operands.',
        stmt.opecode,
      ));
  }
}

Result<List<Code>, ParseError> _parseAdrx(
  Token op,
  Token adr,
  Token x,
  State state,
) {
  final baseOpecode = _parseOpecodeAdrx(String.fromCharCodes(op.runes));
  final indexX = _registerToNumber(x);

  final result = _tokenToCode(adr, state);
  if (result.isError) return result;

  return Result.ok([
    Code((_) => baseOpecode + indexX),
    ...result.ok,
  ]);
}

/// operand pattern: r1,r2
Result<List<Code>, ParseError> parseR1r2(Statement stmt, State state) {
  switch (stmt.operand) {
    case [final r1, final r2]:
      if (r1.type != TokenType.gr) {
        return Result.err(ParseError.fromToken(
          '[SYNTAX ERROR] ${String.fromCharCodes(r1.runes)} is not an expected value. value expects between GR0 and GR7.',
          r1,
        ));
      }
      if (r2.type != TokenType.gr) {
        return Result.err(ParseError.fromToken(
          '[SYNTAX ERROR] ${String.fromCharCodes(r2.runes)} is not an expected value. value expects between GR0 and GR7.',
          r2,
        ));
      }

      return _parseR1r2(stmt.opecode, r1, r2);
    default:
      return Result.err(ParseError.fromToken(
        '[SYNTAX ERROR] ${String.fromCharCodes(stmt.opecode.runes)} wrong number of operands. wants 2 operands.',
        stmt.opecode,
      ));
  }
}

Result<List<Code>, ParseError> _parseR1r2(Token op, Token r1, Token r2) {
  final baseOpecode = _parseOpecodeR1r2(String.fromCharCodes(op.runes));
  final indexR1 = _registerToNumber(r1);
  final indexR2 = _registerToNumber(r2);
  return Result.ok([
    Code((_) => baseOpecode + (indexR1 << 4) + indexR2),
  ]);
}

/// operand pattern: r
Result<List<Code>, ParseError> parseR(Statement stmt, State state) {
  switch (stmt.operand) {
    case [final r]:
      if (r.type != TokenType.gr) {
        return Result.err(ParseError.fromToken(
          '[SYNTAX ERROR] ${String.fromCharCodes(r.runes)} is not an expected value. value expects between GR0 and GR7.',
          r,
        ));
      }

      return _parseR(stmt.opecode, r);
    default:
      return Result.err(ParseError.fromToken(
        '[SYNTAX ERROR] ${String.fromCharCodes(stmt.opecode.runes)} wrong number of operands. wants 1 operands.',
        stmt.opecode,
      ));
  }
}

Result<List<Code>, ParseError> _parseR(Token op, Token r) {
  final baseOpecode = _parseOpecodeR(String.fromCharCodes(op.runes));
  return Result.ok([Code((_) => baseOpecode + (_registerToNumber(r) << 4))]);
}

/// Operand's token to code
///
/// TokenType: string, dec, hex, ref
Result<List<Code>, ParseError> _tokenToCode(Token token, State state) {
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
Result<List<Code>, ParseError> parseDC(Statement stmt, State state) {
  final code = <Code>[];
  for (final token in stmt.operand) {
    final result = _tokenToCode(token, state);
    if (result.isError) return result;
    code.addAll(result.ok);
  }
  return Result.ok(code);
}

Result<List<Code>, ParseError> parseDS(Statement stmt, State state) {
  return Result.ok(List.generate(
    int.parse(String.fromCharCodes(stmt.operand[0].runes)),
    (i) => Code((_) => 0),
  ));
}

Result<List<Code>, ParseError> parseMacro(Macro stmt, State state) {
  final macro = macroList[String.fromCharCodes(stmt.opecode.runes)];
  if (macro == null) {
    return Result.err(ParseError.fromToken(
      '[SYNTAX ERROR] ${String.fromCharCodes(stmt.opecode.runes)} not found.',
      stmt.opecode,
    ));
  }

  return macro(stmt, state);
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