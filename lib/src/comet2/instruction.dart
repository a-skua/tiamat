import 'resource.dart' show Resource, Device;
import './instruction/load_store.dart';
import './instruction/add_sub.dart';
import './instruction/and_or.dart';
import './instruction/shift.dart';
import './instruction/jump.dart';
import './instruction/compare.dart';
import './instruction/stack.dart';
import './instruction/subroutine.dart';
import './instruction/supervisor.dart';
import './instruction/no_operation.dart';

typedef Instruction = Future<void> Function(Resource r, Device d);

Instruction instruction(final int op) {
  return switch (op & 0xff00) {
    0x1000 => load,
    0x1100 => store,
    0x1200 => loadAddress,
    0x1400 => loadGR,
    0x2000 => addArithmetic,
    0x2100 => subtractArithmetic,
    0x2200 => addLogical,
    0x2300 => subtractLogical,
    0x2400 => addArithmeticGR,
    0x2500 => subtractArithmeticGR,
    0x2600 => addLogicalGR,
    0x2700 => subtractLogicalGR,
    0x3000 => and,
    0x3100 => or,
    0x3200 => exclusiveOr,
    0x3400 => andGR,
    0x3500 => orGR,
    0x3600 => exclusiveOrGR,
    0x4000 => compareArithmetic,
    0x4100 => compareLogical,
    0x4400 => compareArithmeticGR,
    0x4500 => compareLogicalGR,
    0x5000 => shiftLeftArithmetic,
    0x5100 => shiftRightArithmetic,
    0x5200 => shiftLeftLogical,
    0x5300 => shiftRightLogical,
    0x6100 => jumpOnMinus,
    0x6200 => jumpOnNonZero,
    0x6300 => jumpOnZero,
    0x6400 => unconditionalJump,
    0x6500 => jumpOnPlus,
    0x6600 => jumpOnOverflow,
    0x7000 => push,
    0x7100 => pop,
    0x8000 => callSubroutine,
    0x8100 => returnFromSubroutine,
    0xf000 => supervisorCall,
    _ => noOperation,
  };
}
