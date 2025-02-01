import '../resource/resource.dart' show Resource, Device;
import './load_store.dart';
import './add_sub.dart';
import './and_or.dart';
import './shift.dart';
import './jump.dart';
import './compare.dart';
import './stack.dart';
import './subroutine.dart';
import './supervisor.dart';
import './no_operation.dart';
import './util.dart';

typedef Instruction = Future<void> Function(Resource r, Device d);

Instruction instruction(final int op) {
  return switch (op.opecode) {
    (0x1, 0x0) => load,
    (0x1, 0x1) => store,
    (0x1, 0x2) => loadAddress,
    (0x1, 0x4) => loadGR,
    (0x2, 0x0) => addArithmetic,
    (0x2, 0x1) => subtractArithmetic,
    (0x2, 0x2) => addLogical,
    (0x2, 0x3) => subtractLogical,
    (0x2, 0x4) => addArithmeticGR,
    (0x2, 0x5) => subtractArithmeticGR,
    (0x2, 0x6) => addLogicalGR,
    (0x2, 0x7) => subtractLogicalGR,
    (0x3, 0x0) => and,
    (0x3, 0x1) => or,
    (0x3, 0x2) => exclusiveOr,
    (0x3, 0x4) => andGR,
    (0x3, 0x5) => orGR,
    (0x3, 0x6) => exclusiveOrGR,
    (0x4, 0x0) => compareArithmetic,
    (0x4, 0x1) => compareLogical,
    (0x4, 0x4) => compareArithmeticGR,
    (0x4, 0x5) => compareLogicalGR,
    (0x5, 0x0) => shiftLeftArithmetic,
    (0x5, 0x1) => shiftRightArithmetic,
    (0x5, 0x2) => shiftLeftLogical,
    (0x5, 0x3) => shiftRightLogical,
    (0x6, 0x1) => jumpOnMinus,
    (0x6, 0x2) => jumpOnNonZero,
    (0x6, 0x3) => jumpOnZero,
    (0x6, 0x4) => unconditionalJump,
    (0x6, 0x5) => jumpOnPlus,
    (0x6, 0x6) => jumpOnOverflow,
    (0x7, 0x0) => push,
    (0x7, 0x1) => pop,
    (0x8, 0x0) => callSubroutine,
    (0x8, 0x1) => returnFromSubroutine,
    (0xf, 0x0) => supervisorCall,
    _ => noOperation,
  };
}
