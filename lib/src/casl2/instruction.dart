import 'node/node.dart';
import 'instruction/instruction.dart';

typedef Parser = void Function(Root r, Tree t);

void instruction(Root r, Tree t) {
  final ins = _map[r.instruction];
  assert(ins != null);
  if (ins != null) {
    ins(r, t);
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
