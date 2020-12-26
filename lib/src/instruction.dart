import 'resource.dart';

class Instruction {
  final _map = List.filled(1 << 8, _noOperation);

  Instruction() {
    this._map[0x10] = this.loadMemory;
    this._map[0x11] = this.store;
    this._map[0x12] = this.loadAddress;
    this._map[0x14] = this.load;

    this._map[0x20] = this.addArithmeticMemory;
    this._map[0x21] = this.subtractArithmeticMemory;
    this._map[0x22] = this.addLogicalMemory;
    this._map[0x23] = this.subtractLogicalMemory;
    this._map[0x24] = this.addArithmetic;
    this._map[0x25] = this.subtractArithmetic;
    this._map[0x26] = this.addLogical;
    this._map[0x27] = this.subtractLogical;

    this._map[0x40] = this.compareArithmeticMemory;
    this._map[0x44] = this.compareArithmetic;

    this._map[0x61] = this.jumpOnMinus;
    this._map[0x62] = this.jumpOnNonZero;
    this._map[0x62] = this.jumpOnZero;
    this._map[0x64] = this.unconditionalJump;
    this._map[0x65] = this.jumpOnPlus;
    this._map[0x66] = this.jumpOnOverflow;

    this._map[0x80] = this.callSubroutine;
    this._map[0x81] = this.returnFromSubroutine;
  }

  void exec(final Resource r) {
    // FIXME conditional
    while (r.SP != 0) {
      final op = (r.memory.getWord(r.PR) >> 8) & 0xff;
      this._map[op](r);
    }
  }

  final noOperation = _noOperation;

  final loadMemory = _loadMemory;
  final store = _store;
  final loadAddress = _loadAddress;
  final load = _load;

  final addArithmeticMemory = _addArithmeticMemory;
  final subtractArithmeticMemory = _subtractArithmeticMemory;
  final addLogicalMemory = _addLogicalMemory;
  final subtractLogicalMemory = _subtractLogicalMemory;
  final addArithmetic = _addArithmetic;
  final subtractArithmetic = _subtractArithmetic;
  final addLogical = _addLogical;
  final subtractLogical = _subtractLogical;

  final compareArithmeticMemory = _compareArithmeticMemory;
  final compareArithmetic = _compareArithmetic;

  final jumpOnMinus = _jumpOnMinus;
  final jumpOnNonZero = _jumpOnNonZero;
  final jumpOnZero = _jumpOnZero;
  final unconditionalJump = _unconditionalJump;
  final jumpOnPlus = _jumpOnPlus;
  final jumpOnOverflow = _jumpOnOverflow;

  final callSubroutine = _callSubroutine;
  final returnFromSubroutine = _returnFromSubroutine;
}

/// NOP
void _noOperation(final Resource r) {
  r.PR += 1;
}

/// LD r,adr,x
void _loadMemory(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final x = cache & 0xf;
  final gr = (cache >> 4) & 0xf;
  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  final data = r.memory.getWord(adr);
  var flag = 0;
  if (data == 0) {
    flag |= zeroFlag;
  }
  if ((data & (1 << (wordSize - 1))) > 0) {
    flag |= signFlag;
  }
  r.setGR(gr, data);
  r.FR = flag;
}

/// LD r1,r2
void _load(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final r2 = cache & 0xf;
  final r1 = (cache >> 4) & 0xf;

  final data = r.getGR(r2);
  var flag = 0;
  if (data == 0) {
    flag |= zeroFlag;
  }
  if ((data & (1 << 15)) > 0) {
    flag |= signFlag;
  }
  r.setGR(r1, data);
  r.FR = flag;
}

/// ST r,adr,x
void _store(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final x = cache & 0xf;
  final gr = (cache >> 4) & 0xf;
  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  r.memory.setWord(adr, r.getGR(gr));
}

/// LAD r, adr, x
void _loadAddress(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final x = cache & 0xf;
  final gr = (cache >> 4) & 0xf;
  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  r.setGR(gr, adr);
}

/// ADDA r,adr,x
void _addArithmeticMemory(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final x = cache & 0xf;
  final gr = (cache >> 4) & 0xf;
  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  const maskBits = (1 << wordSize) - 1;

  final v1 = r.getGR(gr);
  final v2 = r.memory.getWord(adr);
  final result = (v1 + v2) & maskBits;
  final flag = _addaFlag(v1, v2);

  r.setGR(gr, result);
  r.FR = flag;
}

/// ADDA r1,r2
void _addArithmetic(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final r2 = cache & 0xf;
  final r1 = (cache >> 4) & 0xf;

  const maskBits = (1 << wordSize) - 1;

  final v1 = r.getGR(r1);
  final v2 = r.getGR(r2);

  final result = (v1 + v2) & maskBits;
  final flag = _addaFlag(v1, v2);

  r.setGR(r1, result);
  r.FR = flag;
}

/// ADDL r,addr,x
void _addLogicalMemory(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  const maskBits = (1 << wordSize) - 1;

  final x = cache & 0xf;
  final gr = (cache >> 4) & 0xf;
  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  final v1 = r.getGR(gr);
  final v2 = r.memory.getWord(adr);
  final result = (v1 + v2) & maskBits;
  final flag = _addlFlag(v1, v2);

  r.setGR(gr, result);
  r.FR = flag;
}

/// ALLD r1,r2
void _addLogical(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  const maskBits = (1 << wordSize) - 1;

  final r2 = cache & 0xf;
  final r1 = (cache >> 4) & 0xf;
  final v1 = r.getGR(r1);
  final v2 = r.getGR(r2);
  final result = (v1 + v2) & maskBits;
  final flag = _addlFlag(v1, v2);

  r.setGR(r1, result);
  r.FR = flag;
}

/// SUBA r,adr,x
void _subtractArithmeticMemory(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final x = cache & 0xf;
  final gr = (cache >> 4) & 0xf;
  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  const maskBits = (1 << wordSize) - 1;

  final v1 = r.getGR(gr);
  final v2 = _complement2(r.memory.getWord(adr));
  final result = (v1 + v2) & maskBits;
  final flag = _addaFlag(v1, v2);
  r.setGR(gr, result);
  r.FR = flag;
}

/// SUBA r1,r2
void _subtractArithmetic(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final r2 = cache & 0xf;
  final r1 = (cache >> 4) & 0xf;
  const maskBits = (1 << wordSize) - 1;

  final v1 = r.getGR(r1);
  final v2 = _complement2(r.getGR(r2));
  final result = (v1 + v2) & maskBits;
  final flag = _addaFlag(v1, v2);
  r.setGR(r1, result);
  r.FR = flag;
}

/// SUBL r,adr,x
void _subtractLogicalMemory(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final x = cache & 0xf;
  final gr = (cache >> 4) & 0xf;
  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  const maskBits = (1 << wordSize) - 1;

  final v1 = r.getGR(gr);
  final v2 = r.memory.getWord(adr);
  final result = (v1 - v2) & maskBits;
  final flag = _sublFlag(v1, v2);

  r.setGR(gr, result);
  r.FR = flag;
}

/// SUBL r1,r2
void _subtractLogical(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final r2 = cache & 0xf;
  final r1 = (cache >> 4) & 0xf;

  const maskBits = (1 << wordSize) - 1;
  final v1 = r.getGR(r1);
  final v2 = r.getGR(r2);
  final result = (v1 - v2) & maskBits;
  final flag = _sublFlag(v1, v2);

  r.setGR(r1, result);
  r.FR = flag;
}

/// CPA r,adr,x
void _compareArithmeticMemory(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final x = cache & 0xf;
  final gr = (cache >> 4) & 0xf;
  final adr = _getADR(r, x);

  final v1 = r.getGR(gr);
  final v2 = r.memory.getWord(adr);

  r.FR = _cpaFlag(v1, v2);
}

/// CPA r1,r2
void _compareArithmetic(final Resource r) {
  final cache = r.memory.getWord(r.PR);
  r.PR += 1;

  final r2 = cache & 0xf;
  final r1 = (cache >> 4) & 0xf;

  final v1 = r.getGR(r1);
  final v2 = r.getGR(r2);

  r.FR = _cpaFlag(v1, v2);
}

/// JUMP adr,x
void _unconditionalJump(final Resource r) {
  final x = r.memory.getWord(r.PR) & 0xf;
  r.PR += 1;

  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  r.PR = adr;
}

/// JPL adr,x
void _jumpOnPlus(final Resource r) {
  final x = r.memory.getWord(r.PR) & 0xf;
  r.PR += 1;

  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  if (!r.SF && !r.ZF) {
    r.PR = adr;
  }
}

/// JMI adr,x
void _jumpOnMinus(final Resource r) {
  final x = r.memory.getWord(r.PR) & 0xf;
  r.PR += 1;

  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  if (r.SF) {
    r.PR = adr;
  }
}

/// JNZ adr,x
void _jumpOnNonZero(final Resource r) {
  final x = r.memory.getWord(r.PR) & 0xf;
  r.PR += 1;

  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  if (!r.ZF) {
    r.PR = adr;
  }
}

/// JZE adr,x
void _jumpOnZero(final Resource r) {
  final x = r.memory.getWord(r.PR) & 0xf;
  r.PR += 1;

  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  if (r.ZF) {
    r.PR = adr;
  }
}

/// JOV adr,x
void _jumpOnOverflow(final Resource r) {
  final x = r.memory.getWord(r.PR) & 0xf;
  r.PR += 1;

  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  if (r.OF) {
    r.PR = adr;
  }
}

/// CALL adr,x
void _callSubroutine(final Resource r) {
  final x = r.memory.getWord(r.PR) & 0xf;
  r.PR += 1;

  final adr =
      x == 0 ? r.memory.getWord(r.PR) : r.memory.getWord(r.PR) + r.getGR(x);
  r.PR += 1;

  r.SP -= 1;
  r.memory.setWord(r.SP, r.PR);
  r.PR = adr;
}

/// RET
void _returnFromSubroutine(final Resource r) {
  r.PR = r.memory.getWord(r.SP);
  r.SP += 1;
}

int _getADR(final Resource r, final int x) {
  final adr = x == 0
      ? r.memory.getWord(r.PR)
      : (r.memory.getWord(r.PR) + r.getGR(x)) & 0xffff;
  r.PR += 1;
  return adr;
}

int _complement2(final int v) {
  const maskBits = (1 << wordSize) - 1;
  return ((v ^ -1) + 1) & maskBits;
}

int _addaFlag(final int v1, final int v2) {
  const signMask = 1 << (wordSize - 1);
  const maskBits = (1 << wordSize) - 1;
  const overflowMask = maskBits << wordSize;

  final raw = v1 + v2;
  final result = raw & maskBits;

  var flag = 0;
  if ((v1 & signMask) == (v2 & signMask)) {
    if ((raw & overflowMask) > 0) {
      flag |= overflowFlag;
    } else if ((v1 & signMask) != (result & signMask)) {
      flag |= overflowFlag;
    }
  }
  if ((result & signMask) > 0) {
    flag |= signFlag;
  }
  if (result == 0) {
    flag |= zeroFlag;
  }
  return flag;
}

int _addlFlag(final int v1, final int v2) {
  const signMask = 1 << (wordSize - 1);
  const maskBits = (1 << wordSize) - 1;
  const overflowMask = maskBits << wordSize;

  final raw = v1 + v2;
  final result = raw & maskBits;

  var flag = 0;
  if ((raw & overflowMask) > 0) {
    flag |= overflowFlag;
  }
  if ((result & signMask) > 0) {
    flag |= signFlag;
  }
  if (result == 0) {
    flag |= zeroFlag;
  }
  return flag;
}

int _sublFlag(final int v1, final int v2) {
  const maskBits = (1 << wordSize) - 1;
  const signMask = 1 << (wordSize - 1);

  final result = (v1 - v2) & maskBits;

  var flag = 0;
  if (v1 < v2) {
    flag |= overflowFlag;
  }
  if ((result & signMask) > 0) {
    flag |= signFlag;
  }
  if (result == 0) {
    flag |= zeroFlag;
  }
  return flag;
}

int _cpaFlag(final int v1, final int v2) {
  if (v1 == v2) {
    return 1;
  }

  const signMask = 0x8000;
  if ((v1 & signMask == 0 && v2 & signMask == 0) ||
      (v1 & signMask > 0 && v2 & signMask > 0)) {
    if (v1 > v2) {
      return 0;
    } else {
      return 2;
    }
  } else if (v1 & signMask > 0 && v2 & signMask == 0) {
    return 2;
  } else {
    // v1 & signMask == 0 && v2 & signMask > 0
    return 0;
  }
}
