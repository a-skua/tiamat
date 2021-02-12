import 'core/symbol.dart';
import 'core/node.dart';
import 'operand_parser/operand_parser.dart';

typedef Parser = void Function(Symbol s, Tree t);

void parse(Symbol s, Tree t) {
  final parse = _map[String.fromCharCodes(s.opecode)];
  assert(parse != null);
  if (parse != null) {
    parse(s, t);
  }
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
