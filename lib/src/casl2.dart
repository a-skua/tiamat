import './casl2/node.dart' as node;
import './casl2/instruction.dart';

class Casl2 {
  List<int> compile(final String s) {
    return this.trans(this.parse(s));
  }

  List<Token> parse(final String s) {
    final Map<String, int> l = {};
    final List<Token> t = [];
    var count = 0;

    for (final n in node.parse(s)) {
      final label = n.label;
      final code = n.instruction;
      final operand = n.operand;

      if (code.isEmpty) {
        continue;
      }
      var token = nop(label);
      switch (code) {
        case 'START':
          token = start(label, operand);
          break;
        case 'END':
          token = end();
          break;
        case 'DS':
          token = ds(label, operand);
          break;
        case 'DC':
          // TODO bug; DC 'hello, world!'
          token = dc(label, operand);
          break;
        case 'IN':
          token = input(label, operand);
          break;
        case 'OUT':
          token = output(label, operand);
          break;
        case 'RPUSH':
          token = rpush(label);
          break;
        case 'RPOP':
          token = rpop(label);
          break;
        case 'LD':
          token = ld(label, operand);
          break;
        case 'LAD':
          token = lad(label, operand);
          break;
        case 'ST':
          token = st(label, operand);
          break;
        case 'ADDA':
          token = adda(label, operand);
          break;
        case 'ADDL':
          token = addl(label, operand);
          break;
        case 'SUBA':
          token = suba(label, operand);
          break;
        case 'SUBL':
          token = subl(label, operand);
          break;
        case 'AND':
          token = and(label, operand);
          break;
        case 'OR':
          token = or(label, operand);
          break;
        case 'XOR':
          token = xor(label, operand);
          break;
        case 'CPA':
          token = cpa(label, operand);
          break;
        case 'CPL':
          token = cpl(label, operand);
          break;
        case 'SLA':
          token = sla(label, operand);
          break;
        case 'SRA':
          token = sra(label, operand);
          break;
        case 'SLL':
          token = sll(label, operand);
          break;
        case 'SRL':
          token = srl(label, operand);
          break;
        case 'JMI':
          token = jmi(label, operand);
          break;
        case 'JNZ':
          token = jnz(label, operand);
          break;
        case 'JZE':
          token = jze(label, operand);
          break;
        case 'JUMP':
          token = jump(label, operand);
          break;
        case 'JPL':
          token = jpl(label, operand);
          break;
        case 'JOV':
          token = jov(label, operand);
          break;
        case 'PUSH':
          token = push(label, operand);
          break;
        case 'POP':
          token = pop(label, operand);
          break;
        case 'CALL':
          token = call(label, operand);
          break;
        case 'RET':
          token = ret(label);
          break;
        case 'SVC':
          token = svc(label, operand);
          break;
        // case 'NOP':
        //   break;
      }
      if (token.hasLabel) {
        l[token.label] = count;
      }
      count += token.size;
      t.add(token);
    }

    for (var token in t) {
      if (token.hasReferenceLabel) {
        final label = l[token.refLabel];
        if (label != null) {
          token.setLabel(label);
        }
      }
    }
    return t;
  }

  List<int> trans(final List<Token> tokens) {
    final List<int> c = [];
    for (var t in tokens) {
      if (t.code.isNotEmpty) {
        c.addAll(t.code);
      }
    }
    return c;
  }
}
