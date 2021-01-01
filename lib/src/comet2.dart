import 'instruction.dart';
import 'resource.dart';
import 'supervisorcall.dart';

class Comet2 {
  final _map = <int, Instruction>{};

  final sv = Supervisor();

  Comet2() {
    this._map[0x10] = loadMemory;
    this._map[0x11] = store;
    this._map[0x12] = loadAddress;
    this._map[0x14] = load;

    this._map[0x20] = addArithmeticMemory;
    this._map[0x21] = subtractArithmeticMemory;
    this._map[0x22] = addLogicalMemory;
    this._map[0x23] = subtractLogicalMemory;
    this._map[0x24] = addArithmetic;
    this._map[0x25] = subtractArithmetic;
    this._map[0x26] = addLogical;
    this._map[0x27] = subtractLogical;

    this._map[0x30] = andMemory;
    this._map[0x31] = orMemory;
    this._map[0x32] = exclusiveOrMemory;
    this._map[0x34] = and;
    this._map[0x35] = or;
    this._map[0x36] = exclusiveOr;

    this._map[0x40] = compareArithmeticMemory;
    this._map[0x41] = compareLogicalMemory;
    this._map[0x44] = compareArithmetic;
    this._map[0x45] = compareLogical;

    this._map[0x50] = shiftLeftArithmetic;
    this._map[0x51] = shiftRightArithmetic;
    this._map[0x52] = shiftLeftLogical;
    this._map[0x53] = shiftRightLogical;

    this._map[0x61] = jumpOnMinus;
    this._map[0x62] = jumpOnNonZero;
    this._map[0x62] = jumpOnZero;
    this._map[0x64] = unconditionalJump;
    this._map[0x65] = jumpOnPlus;
    this._map[0x66] = jumpOnOverflow;

    this._map[0x70] = push;
    this._map[0x71] = pop;

    this._map[0x80] = callSubroutine;
    this._map[0x81] = returnFromSubroutine;

    this._map[0xf0] = this._supervisorCall;
  }

  void exec(final Resource r) {
    // FIXME conditional
    while (r.SP != 0) {
      final op = (r.memory.getWord(r.PR) >> 8) & 0xff;
      final ins = this._map[op] ?? noOperation;
      ins(r);
    }
  }

  void _supervisorCall(final Resource r) {
    supervisorCall(r, this.sv);
  }
}
