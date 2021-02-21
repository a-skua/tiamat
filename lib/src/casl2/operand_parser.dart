import 'core/error.dart';
import 'core/symbol.dart';
import 'core/error.dart';
import 'core/node_tree.dart';
import 'operand_parser/operand_parser.dart';

typedef Parser = Error? Function(Symbol, NodeTree);

Error? parse(Symbol s, NodeTree t) {
  final opecode = String.fromCharCodes(s.opecode);
  final parse = _map[opecode];

  if (parse != null) {
    final error = parse(s, t);
    if (error != null) {
      // TODO
      final label = String.fromCharCodes(s.label);
      final operand = String.fromCharCodes(s.operand);
      final comment = String.fromCharCodes(s.comment);
      return Error(
        '---\n'
        'info\n'
        '\tlabel:\t $label\n'
        '\topecode: $opecode\n'
        '\toperand: $operand\n'
        '\tcomment: $comment\n'
        '${error.detail}',
        ErrorType.operand,
      );
    }
  } else {
    return Error(
      '---\n'
      'Not implements $opecode',
      ErrorType.opecode,
    );
  }
  return null;
}

final _map = <String, Parser>{
  'START': start,
  'END': end,
  'DS': ds,
  'DC': dc,
  'NOP': nop,
  'LD': ld,
  'LAD': lad,
  'ST': st,
  'ADDA': adda,
  'ADDL': addl,
  'SUBA': suba,
  'SUBL': subl,
  'AND': and,
  'OR': or,
  'XOR': xor,
  'CPA': cpa,
  'CPL': cpl,
  'SLA': sla,
  'SRA': sra,
  'SLL': sll,
  'SRL': srl,
  'JMI': jmi,
  'JNZ': jnz,
  'JZE': jze,
  'JUMP': jump,
  'JPL': jpl,
  'JOV': jov,
  'PUSH': push,
  'POP': pop,
  'CALL': call,
  'RET': ret,
  'SVC': svc,
  'IN': input,
  'OUT': output,
  'RPUSH': rpush,
  'RPOP': rpop,
};
