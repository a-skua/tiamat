import 'instruction.dart';
import 'resource.dart';

class Comet2 {
  final _map = List.filled(1 << 8, Instruction.noOperation);

  Comet2() {
    this._map[0x10] = Instruction.loadMemory;
    this._map[0x11] = Instruction.store;
    this._map[0x12] = Instruction.loadAddress;
    this._map[0x14] = Instruction.load;

    this._map[0x20] = Instruction.addArithmeticMemory;
    this._map[0x21] = Instruction.subtractArithmeticMemory;
    this._map[0x22] = Instruction.addLogicalMemory;
    this._map[0x23] = Instruction.subtractLogicalMemory;
    this._map[0x24] = Instruction.addArithmetic;
    this._map[0x25] = Instruction.subtractArithmetic;
    this._map[0x26] = Instruction.addLogical;
    this._map[0x27] = Instruction.subtractLogical;

    this._map[0x40] = Instruction.compareArithmeticMemory;
    this._map[0x41] = Instruction.compareLogicalMemory;
    this._map[0x44] = Instruction.compareArithmetic;
    this._map[0x45] = Instruction.compareLogical;

    this._map[0x61] = Instruction.jumpOnMinus;
    this._map[0x62] = Instruction.jumpOnNonZero;
    this._map[0x62] = Instruction.jumpOnZero;
    this._map[0x64] = Instruction.unconditionalJump;
    this._map[0x65] = Instruction.jumpOnPlus;
    this._map[0x66] = Instruction.jumpOnOverflow;

    this._map[0x70] = Instruction.push;
    this._map[0x71] = Instruction.pop;

    this._map[0x80] = Instruction.callSubroutine;
    this._map[0x81] = Instruction.returnFromSubroutine;
  }

  void exec(final Resource r) {
    // FIXME conditional
    while (r.SP != 0) {
      final op = (r.memory.getWord(r.PR) >> 8) & 0xff;
      this._map[op](r);
    }
  }
}
