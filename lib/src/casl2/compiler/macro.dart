import '../../typedef/typedef.dart';
import '../parser/parser.dart' show Macro, Statement;
import './compiler.dart' show CompileError;
import './const.dart';

final embeddedMacro =
    <String, Result<List<Statement>, CompileError> Function(Macro stmt)>{
  'IN': _in,
  'OUT': _out,
  'RPUSH': _rpush,
  'RPOP': _rpop,
};

Result<List<Statement>, CompileError> _in(Macro stmt) {
  switch (stmt.operand) {
    case [final buf, final len]:
      if (len.isNotHex && len.isNotDec) {
        return Err(CompileError.fromToken(
          '[SYNTAX ERROR] ${String.fromCharCodes(len.runes)} wrong type. wants a number.',
          len,
        ));
      }

      return Ok([
        Statement(lad, operand: [gr1, buf], label: stmt.label),
        Statement(lad, operand: [gr2, len]),
        Statement(svc, operand: [dec1]),
      ]);
    default:
      return Err(CompileError.fromToken(
        '[SYNTAX ERROR] ${String.fromCharCodes(stmt.opecode.runes)} wrong number of operands. wants 2 operands.',
        stmt.opecode,
      ));
  }
}

Result<List<Statement>, CompileError> _out(Macro stmt) {
  switch (stmt.operand) {
    case [final buf, final len]:
      if (len.isNotHex && len.isNotDec) {
        return Err(CompileError.fromToken(
          '[SYNTAX ERROR] ${String.fromCharCodes(len.runes)} wrong type. wants a number.',
          len,
        ));
      }

      return Ok([
        Statement(lad, operand: [gr1, buf], label: stmt.label),
        Statement(lad, operand: [gr2, len]),
        Statement(svc, operand: [dec2]),
      ]);
    default:
      return Err(CompileError.fromToken(
        '[SYNTAX ERROR] ${String.fromCharCodes(stmt.opecode.runes)} wrong number of operands. wants 2 operands.',
        stmt.opecode,
      ));
  }
}

Result<List<Statement>, CompileError> _rpush(Macro stmt) {
  return Ok([
    Statement(push, operand: [dec0, gr1], label: stmt.label),
    Statement(push, operand: [dec0, gr2]),
    Statement(push, operand: [dec0, gr3]),
    Statement(push, operand: [dec0, gr4]),
    Statement(push, operand: [dec0, gr5]),
    Statement(push, operand: [dec0, gr6]),
    Statement(push, operand: [dec0, gr7]),
  ]);
}

Result<List<Statement>, CompileError> _rpop(Macro stmt) {
  return Ok([
    Statement(pop, operand: [gr7], label: stmt.label),
    Statement(pop, operand: [gr6]),
    Statement(pop, operand: [gr5]),
    Statement(pop, operand: [gr4]),
    Statement(pop, operand: [gr3]),
    Statement(pop, operand: [gr2]),
    Statement(pop, operand: [gr1]),
  ]);
}
