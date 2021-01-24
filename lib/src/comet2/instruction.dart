import 'resource.dart';
import 'instruction/instruction.dart';

typedef Instruction = void Function(Resource r);

void instruction(final Resource r, final int code) {
  final ins = _map[code] ?? noOperation;
  ins(r);
}

final _map = <int, Instruction>{
  0x10: load,
  0x11: store,
  0x12: loadAddress,
  0x14: loadGR,
  0x20: addArithmetic,
  0x21: subtractArithmetic,
  0x22: addLogical,
  0x23: subtractLogical,
  0x24: addArithmeticGR,
  0x25: subtractArithmeticGR,
  0x26: addLogicalGR,
  0x27: subtractLogicalGR,
  0x30: and,
  0x31: or,
  0x32: exclusiveOr,
  0x34: andGR,
  0x35: orGR,
  0x36: exclusiveOrGR,
  0x40: compareArithmetic,
  0x41: compareLogical,
  0x44: compareArithmeticGR,
  0x45: compareLogicalGR,
  0x50: shiftLeftArithmetic,
  0x51: shiftRightArithmetic,
  0x52: shiftLeftLogical,
  0x53: shiftRightLogical,
  0x61: jumpOnMinus,
  0x62: jumpOnNonZero,
  0x63: jumpOnZero,
  0x64: unconditionalJump,
  0x65: jumpOnPlus,
  0x66: jumpOnOverflow,
  0x70: push,
  0x71: pop,
  0x80: callSubroutine,
  0x81: returnFromSubroutine,
  0xf0: supervisorCall,
};
