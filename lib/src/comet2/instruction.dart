import 'resource.dart' show Resource;
import './instruction/instruction.dart';

typedef Instruction = void Function(Resource r);

Instruction instruction(final int op) {
  switch (op & 0xff00) {
    case 0x1000:
      return load;
    case 0x1100:
      return store;
    case 0x1200:
      return loadAddress;
    case 0x1400:
      return loadGR;
    case 0x2000:
      return addArithmetic;
    case 0x2100:
      return subtractArithmetic;
    case 0x2200:
      return addLogical;
    case 0x2300:
      return subtractLogical;
    case 0x2400:
      return addArithmeticGR;
    case 0x2500:
      return subtractArithmeticGR;
    case 0x2600:
      return addLogicalGR;
    case 0x2700:
      return subtractLogicalGR;
    case 0x3000:
      return and;
    case 0x3100:
      return or;
    case 0x3200:
      return exclusiveOr;
    case 0x3400:
      return andGR;
    case 0x3500:
      return orGR;
    case 0x3600:
      return exclusiveOrGR;
    case 0x4000:
      return compareArithmetic;
    case 0x4100:
      return compareLogical;
    case 0x4400:
      return compareArithmeticGR;
    case 0x4500:
      return compareLogicalGR;
    case 0x5000:
      return shiftLeftArithmetic;
    case 0x5100:
      return shiftRightArithmetic;
    case 0x5200:
      return shiftLeftLogical;
    case 0x5300:
      return shiftRightLogical;
    case 0x6100:
      return jumpOnMinus;
    case 0x6200:
      return jumpOnNonZero;
    case 0x6300:
      return jumpOnZero;
    case 0x6400:
      return unconditionalJump;
    case 0x6500:
      return jumpOnPlus;
    case 0x6600:
      return jumpOnOverflow;
    case 0x7000:
      return push;
    case 0x7100:
      return pop;
    case 0x8000:
      return callSubroutine;
    case 0x8100:
      return returnFromSubroutine;
    case 0xf000:
      return supervisorCall;
    default:
      return noOperation;
  }
}
