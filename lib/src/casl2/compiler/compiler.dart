import '../../typedef/typedef.dart';
import '../parser/ast.dart';
import '../lexer/token.dart';
import './state.dart';
import './util.dart';
import '../casl2.dart';

/// Code of COMET2
class Code {
  final int Function(Position) _value;

  Code(this._value);

  int value([Position base = 0]) => _value(base);
}

/// Error of Compiler
/// TODO [ParseError]
final class CompileError extends Casl2Error {
  const CompileError(
    String message, {
    required int start,
    required int end,
    required int lineStart,
    required int lineNumber,
  }) : super(
          message,
          start: start,
          end: end,
          lineStart: lineStart,
          lineNumber: lineNumber,
        );

  factory CompileError.fromToken(String message, Token token) => CompileError(
        message,
        start: token.start,
        end: token.end,
        lineStart: token.lineStart,
        lineNumber: token.lineNumber,
      );
}

abstract class Compiler {
  /// Compile the source code.
  Result<List<Code>, CompileError> compile(Statement stmt);

  factory Compiler() => _Compler(State());
}

final class _Compler implements Compiler {
  final State _state;

  const _Compler(this._state);

  @override
  Result<List<Code>, CompileError> compile(Statement stmt) =>
      _compile(stmt, _state);
}

Result<List<Code>, CompileError> _compile(Statement stmt, State state) {
  switch (String.fromCharCodes(stmt.opecode.runes)) {
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
      return parseGeneral(stmt, state);
    case 'ST':
    case 'LAD':
    case 'SLA':
    case 'SRA':
    case 'SLL':
    case 'SRL':
      return parseRadrx(stmt, state);
    case 'JMI':
    case 'JNZ':
    case 'JZE':
    case 'JUMP':
    case 'JPL':
    case 'JOV':
    case 'PUSH':
    case 'CALL':
    case 'SVC':
      return parseAdrx(stmt, state);
    case 'POP':
      return parseR(stmt, state);
    case 'RET':
      return Ok([Code((_) => 0x8100)]);
    case 'NOP':
      return Ok([Code((_) => 0)]);
    case '':
    case 'START':
    case 'END':
      return Ok([]);
    case 'DC':
      return parseDC(stmt, state);
    case 'DS':
      return parseDS(stmt, state);
    default:
      return parseMacro(stmt as Macro, state);
  }
}
