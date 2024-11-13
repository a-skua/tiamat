import '../lexer/token.dart';
import './ast.dart';
import './util.dart';
import './parser.dart';
import '../../typedef/typedef.dart';
import '../compiler/state.dart';

final macroList = <String,
    Result<List<Code>, ParseError> Function(
  Macro macro,
  State state,
)>{
  'IN': parseIN,
  'OUT': parseOUT,
  'RPUSH': parseRPUSH,
  'RPOP': parseRPOP,
};

final _lad = Token.op('LAD'.runes);
final _svc = Token.op('SVC'.runes);
final _push = Token.op('PUSH'.runes);
final _pop = Token.op('POP'.runes);
final _gr1 = Token.gr('GR1'.runes);
final _gr2 = Token.gr('GR2'.runes);
final _gr3 = Token.gr('GR3'.runes);
final _gr4 = Token.gr('GR4'.runes);
final _gr5 = Token.gr('GR5'.runes);
final _gr6 = Token.gr('GR6'.runes);
final _gr7 = Token.gr('GR7'.runes);
final _dec0 = Token.dec('0'.runes);
final _dec1 = Token.dec('1'.runes);
final _dec2 = Token.dec('2'.runes);

Result<List<Code>, ParseError> parseIN(Macro stmt, State state) {
  switch (stmt.operand) {
    case [final buf, final len]:
      if (len.type != TokenType.hex && len.type != TokenType.dec) {
        return Err(ParseError.fromToken(
          '[SYNTAX ERROR] ${String.fromCharCodes(len.runes)} wrong type. wants a number.',
          len,
        ));
      }

      return [
        parseRadrx(
          Statement(_lad, operand: [_gr1, buf]),
          state,
        ),
        parseRadrx(
          Statement(_lad, operand: [_gr2, buf]),
          state,
        ),
        parseAdrx(
          Statement(_svc, operand: [_dec1]),
          state,
        ),
      ].reduce((a, b) {
        if (a.isErr) return a;
        if (b.isErr) return b;

        a.ok.addAll(b.ok);
        return a;
      });
    default:
      return Err(ParseError.fromToken(
        '[SYNTAX ERROR] ${String.fromCharCodes(stmt.opecode.runes)} wrong number of operands. wants 2 operands.',
        stmt.opecode,
      ));
  }
}

Result<List<Code>, ParseError> parseOUT(Macro stmt, State state) {
  switch (stmt.operand) {
    case [final buf, final len]:
      if (len.type != TokenType.hex && len.type != TokenType.dec) {
        return Err(ParseError.fromToken(
          '[SYNTAX ERROR] ${String.fromCharCodes(len.runes)} wrong type. wants a number.',
          len,
        ));
      }

      return [
        parseRadrx(
          Statement(_lad, operand: [_gr1, buf]),
          state,
        ),
        parseRadrx(
          Statement(_lad, operand: [_gr2, len]),
          state,
        ),
        parseAdrx(
          Statement(_svc, operand: [_dec2]),
          state,
        ),
      ].reduce((a, b) {
        if (a.isErr) return a;
        if (b.isErr) return b;

        a.ok.addAll(b.ok);
        return a;
      });
    default:
      return Err(ParseError.fromToken(
        '[SYNTAX ERROR] ${String.fromCharCodes(stmt.opecode.runes)} wrong number of operands. wants 2 operands.',
        stmt.opecode,
      ));
  }
}

Result<List<Code>, ParseError> parseRPUSH(Macro stmt, State state) {
  return [
    parseAdrx(
      Statement(_push, operand: [_dec0, _gr1]),
      state,
    ),
    parseAdrx(
      Statement(_push, operand: [_dec0, _gr2]),
      state,
    ),
    parseAdrx(
      Statement(_push, operand: [_dec0, _gr3]),
      state,
    ),
    parseAdrx(
      Statement(_push, operand: [_dec0, _gr4]),
      state,
    ),
    parseAdrx(
      Statement(_push, operand: [_dec0, _gr5]),
      state,
    ),
    parseAdrx(
      Statement(_push, operand: [_dec0, _gr6]),
      state,
    ),
    parseAdrx(
      Statement(_push, operand: [_dec0, _gr7]),
      state,
    ),
  ].reduce((a, b) {
    if (a.isErr) return a;
    if (b.isErr) return b;

    a.ok.addAll(b.ok);
    return a;
  });
}

Result<List<Code>, ParseError> parseRPOP(Macro stmt, State state) {
  return [
    parseR(
      Statement(_pop, operand: [_gr7]),
      state,
    ),
    parseR(
      Statement(_pop, operand: [_gr6]),
      state,
    ),
    parseR(
      Statement(_pop, operand: [_gr5]),
      state,
    ),
    parseR(
      Statement(_pop, operand: [_gr4]),
      state,
    ),
    parseR(
      Statement(_pop, operand: [_gr3]),
      state,
    ),
    parseR(
      Statement(_pop, operand: [_gr2]),
      state,
    ),
    parseR(
      Statement(_pop, operand: [_gr1]),
      state,
    ),
  ].reduce((a, b) {
    if (a.isErr) return a;
    if (b.isErr) return b;

    a.ok.addAll(b.ok);
    return a;
  });
}
