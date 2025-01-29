import 'package:tiamat/typedef.dart';
import './parser.dart' show Subroutine, Statement, Macro;
import './lexer.dart' show Token;
import './casl2.dart' show Casl2Error;
import './charcode.dart' show RuneToReal;
import './word.dart';
import './compiler/macro.dart';
import './compiler/const.dart';

/// Error of [Compiler]
final class CompileError extends Casl2Error {
  const CompileError(
    super.message, {
    required super.start,
    required super.end,
    required super.lineStart,
    required super.lineNumber,
  });

  factory CompileError.fromToken(String message, Token token) => CompileError(
        message,
        start: token.start,
        end: token.end,
        lineStart: token.lineStart,
        lineNumber: token.lineNumber,
      );
}

/// [Compiler] of CASL2
abstract class Compiler {
  /// Compile the source code.
  Result<Words, CompileError> compile(Statement stmt);

  factory Compiler() => _Compler();
}

final class _Compler implements Compiler {
  const _Compler();

  @override
  Result<Words, CompileError> compile(Statement stmt) {
    return _compile(stmt).map((words) => Words(stmt.label?.string, words));
  }
}

Result<List<Word>, CompileError> _compile(Statement stmt) {
  switch (stmt.opecode.string) {
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
      return _compileGeneral(stmt);
    case 'ST':
    case 'LAD':
    case 'SLA':
    case 'SRA':
    case 'SLL':
    case 'SRL':
      return _compileRadrx(stmt);
    case 'JMI':
    case 'JNZ':
    case 'JZE':
    case 'JUMP':
    case 'JPL':
    case 'JOV':
    case 'PUSH':
    case 'CALL':
    case 'SVC':
      return _compileAdrx(stmt);
    case 'POP':
      return _compileR(stmt);
    case 'RET':
      final label = stmt.label;
      return Ok([
        Constant(0x8100, [if (label != null) label.string])
      ]);
    case 'NOP':
      final label = stmt.label;
      return Ok([
        Constant(0, [if (label != null) label.string])
      ]);
    case '':
    case 'START':
      if (stmt is! Subroutine) {
        return Err(CompileError.fromToken(
          '[SYNTAX ERROR] ${stmt.opecode.string} is not an expected value. value expects a subroutine.',
          stmt.opecode,
        ));
      }
      return _compileSTART(stmt);
    case 'END':
      return Ok([]);
    case 'DC':
      return _compileDC(stmt);
    case 'DS':
      return _compileDS(stmt);
    default:
      return _compileMacro(stmt as Macro);
  }
}

extension RegisterToNumber on Token {
  int get grNumber => int.parse(string.replaceFirst('GR', ''));
}

/// operand pattern: r1,r2 | r,adr(,x)
Result<List<Word>, CompileError> _compileGeneral(Statement stmt) {
  switch (stmt.operand) {
    case [_, final r2] when r2.isGr:
      return _compileR1r2(stmt);
    default:
      return _compileRadrx(stmt);
  }
}

/// operand pattern: r,adr(,x)
Result<List<Word>, CompileError> _compileRadrx(Statement stmt) {
  Result<List<Word>, CompileError> compileRadrx(
    Token op,
    Token r,
    Token adr,
    Token x,
  ) {
    final baseOpecode = op.radrxReal;
    final indexR = r.grNumber;
    final indexX = x.grNumber;

    final result = _compileOperand(adr);
    if (result.isErr) return result;

    final label = stmt.label;
    return Ok([
      Constant(
        baseOpecode + (indexR << 4) + indexX,
        [if (label != null) label.string],
      ),
      ...result.ok,
    ]);
  }

  switch (stmt.operand) {
    case [final r, _] when r.isNotGr:
      return Err(CompileError.fromToken(
        '[SYNTAX ERROR] ${r.string} is not an expected value. value expects between GR0 and GR7.',
        r,
      ));
    case [final r, final adr]:
      return compileRadrx(stmt.opecode, r, adr, gr0);
    case [final r, _, _] when r.isNotGr:
      return Err(CompileError.fromToken(
        '[SYNTAX ERROR] ${r.string} is not an expected value. value expects between GR0 and GR7.',
        r,
      ));
    case [_, _, final x] when x.isNotGr:
      return Err(CompileError.fromToken(
        '[SYNTAX ERROR] ${x.string} is not an expected value. value expects between GR1 and GR7.',
        x,
      ));
    case [_, _, final x] when x.string == 'GR0':
      return Err(CompileError.fromToken(
        '[SYNTAX ERROR] ${x.string} is not an expected value. value expects between GR1 and GR7.',
        x,
      ));
    case [final r, final adr, final x]:
      return compileRadrx(stmt.opecode, r, adr, x);
    default:
      return Err(CompileError.fromToken(
        '[SYNTAX ERROR] ${stmt.opecode.string} wrong number of operands. wants 2 or 3 operands.',
        stmt.opecode,
      ));
  }
}

/// operand pattern: r1,r2
Result<List<Word>, CompileError> _compileR1r2(Statement stmt) {
  Result<List<Word>, CompileError> compileR1r2(Token op, Token r1, Token r2) {
    final label = stmt.label;
    return Ok([
      Constant(
        op.r1r2Real + (r1.grNumber << 4) + r2.grNumber,
        [if (label != null) label.string],
      ),
    ]);
  }

  switch (stmt.operand) {
    case [final r1, _] when r1.isNotGr:
      return Err(CompileError.fromToken(
        '[SYNTAX ERROR] ${r1.string} is not an expected value. value expects between GR0 and GR7.',
        r1,
      ));
    case [_, final r2] when r2.isNotGr:
      return Err(CompileError.fromToken(
        '[SYNTAX ERROR] ${r2.string} is not an expected value. value expects between GR0 and GR7.',
        r2,
      ));
    case [final r1, final r2]:
      return compileR1r2(stmt.opecode, r1, r2);
    default:
      return Err(CompileError.fromToken(
        '[SYNTAX ERROR] ${stmt.opecode.string} wrong number of operands. wants 2 operands.',
        stmt.opecode,
      ));
  }
}

/// operand pattern: adr(,x)
Result<List<Word>, CompileError> _compileAdrx(Statement stmt) {
  Result<List<Word>, CompileError> compileAdrx(Token op, Token adr, Token x) {
    final result = _compileOperand(adr);
    if (result.isErr) return result;

    final label = stmt.label;
    return Ok([
      Constant(op.adrxReal + x.grNumber, [if (label != null) label.string]),
      ...result.ok,
    ]);
  }

  switch (stmt.operand) {
    case [final adr]:
      return compileAdrx(stmt.opecode, adr, gr0);
    case [final adr, final x]:
      return compileAdrx(stmt.opecode, adr, x);
    default:
      return Err(CompileError.fromToken(
        '[SYNTAX ERROR] ${stmt.opecode.string} wrong number of operands. wants 1 or 2 operands.',
        stmt.opecode,
      ));
  }
}

/// operand pattern: r
Result<List<Word>, CompileError> _compileR(Statement stmt) {
  Result<List<Word>, CompileError> compileR(Token op, Token r) {
    final label = stmt.label;
    return Ok([
      Constant(op.rReal + (r.grNumber << 4), [if (label != null) label.string])
    ]);
  }

  switch (stmt.operand) {
    case [final r] when r.isNotGr:
      return Err(CompileError.fromToken(
        '[SYNTAX ERROR] ${r.string} is not an expected value. value expects between GR0 and GR7.',
        r,
      ));
    case [final r]:
      return compileR(stmt.opecode, r);
    default:
      return Err(CompileError.fromToken(
        '[SYNTAX ERROR] ${stmt.opecode.string} wrong number of operands. wants 1 operands.',
        stmt.opecode,
      ));
  }
}

/// Operand's token to code
///
/// [Token] is string, dec, hex, ref
Result<List<Word>, CompileError> _compileOperand(Token token) {
  switch (token) {
    case final token when token.isText:
      // "'is''s a small world'" to "'is's a small world'"
      final str = token.string.replaceAll("''", "'");

      final code = <Word>[];
      for (final rune in str.substring(1, str.length - 1).runes) {
        code.add(Constant(rune.real, []));
      }
      return Ok(code);
    case final token when token.isDec:
      return Ok([
        Constant(int.parse(token.string), []),
      ]);
    case final token when token.isHex:
      return Ok([
        Constant(int.parse(token.string.replaceFirst('#', '0x')), []),
      ]);
    case final token when token.isRef:
      return Ok([Reference(token, [])]);
    default:
      return Err(CompileError.fromToken(
        '[SYNTAX ERROR] unexpected token: $token',
        token,
      ));
  }
}

/// OPECODE: DC
Result<List<Word>, CompileError> _compileDC(Statement stmt) {
  final words = <Word>[];
  for (final token in stmt.operand) {
    final result = _compileOperand(token);
    if (result.isErr) return result;
    words.addAll(result.ok);
  }

  final label = stmt.label;
  if (label != null) {
    words.first.labels.add(label.string);
  }
  return Ok(words);
}

Result<List<Word>, CompileError> _compileDS(Statement stmt) {
  return Ok(List.generate(
    int.parse(stmt.operand[0].string),
    (i) {
      if (i != 0) return Constant(0, []);
      final label = stmt.label;
      return Constant(0, [if (label != null) label.string]);
    },
  ));
}

Result<List<Word>, CompileError> _compileMacro(Macro stmt) {
  final macro = embeddedMacro[stmt.opecode.string];
  if (macro == null) {
    return Err(CompileError.fromToken(
      '[SYNTAX ERROR] Macro ${stmt.opecode.string} not found.',
      stmt.opecode,
    ));
  }

  final result = macro(stmt);
  if (result.isErr) {
    return Err(result.err);
  }

  return result.ok.map((stmt) => _compile(stmt)).reduce((a, b) {
    if (a.isErr) return a;
    if (b.isErr) return b;

    a.ok.addAll(b.ok);
    return a;
  });
}

Result<List<Word>, CompileError> _compileSTART(Subroutine stmt) {
  final words = <Word>[];
  for (final stmt in stmt.process) {
    final result = _compile(stmt);
    if (result.isErr) return result;

    words.addAll(result.ok);
  }

  switch ((stmt.label, stmt.operand)) {
    case (final label, [final ref]) when label != null:
      final refLabel = ref.string;
      words
          .firstWhere((word) => word.labels.contains(refLabel))
          .labels
          .add(label.string);
      break;
    case (final label, []) when label != null:
      words.first.labels.add(label.string);
      break;
  }

  return Ok(words);
}

/// [Token] to [Real]
extension OpecodeToReal on Token {
  Real get r1r2Real => switch (string) {
        'LD' => 0x1400,
        'ADDA' => 0x2400,
        'SUBA' => 0x2500,
        'ADDL' => 0x2600,
        'SUBL' => 0x2700,
        'AND' => 0x3400,
        'OR' => 0x3500,
        'XOR' => 0x3600,
        'CPA' => 0x4400,
        'CPL' => 0x4500,
        _ => 0,
      };

  Real get radrxReal => switch (string) {
        'LD' => 0x1000,
        'ST' => 0x1100,
        'LAD' => 0x1200,
        'ADDA' => 0x2000,
        'SUBA' => 0x2100,
        'ADDL' => 0x2200,
        'SUBL' => 0x2300,
        'AND' => 0x3000,
        'OR' => 0x3100,
        'XOR' => 0x3200,
        'CPA' => 0x4000,
        'CPL' => 0x4100,
        'SLA' => 0x5000,
        'SRA' => 0x5100,
        'SLL' => 0x5200,
        'SRL' => 0x5300,
        _ => 0,
      };

  Real get adrxReal => switch (string) {
        'JMI' => 0x6100,
        'JNZ' => 0x6200,
        'JZE' => 0x6300,
        'JUMP' => 0x6400,
        'JPL' => 0x6500,
        'JOV' => 0x6600,
        'PUSH' => 0x7000,
        'CALL' => 0x8000,
        'SVC' => 0xf000,
        _ => 0,
      };

  Real get rReal => switch (string) {
        'POP' => 0x7100,
        _ => 0,
      };
}
