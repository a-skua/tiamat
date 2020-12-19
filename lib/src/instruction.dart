import 'resource.dart';

class Instruction {
  final noOperation = _noOperation;
  final loadMemory = _loadMemory;
  final store = _store;
  final loadAddress = _loadAddress;
  final load = _load;
  final addArithmeticMemory = _addArithmeticMemory;
  final addArithmetic = _addArithmetic;
  final subtractArithmeticMemory = _subtractArithmeticMemory;
  final subtractArithmetic = _subtractArithmetic;
  final addLogicalMemory = _addLogicalMemory;
  final addLogical = _addLogical;
  final subtractLogicalMemory = _subtractLogicalMemory;
}

/// NOP
void _noOperation(final Resource r) {
  r.PR += 1;
}

/// LD r, adr, x
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

/// LD r1, r2
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

/// ST r, adr, x
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

/// ADDA r, adr, x
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

/// ADDA r1, r2
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

/// ADDL r, addr, x
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

/// ALLD r1, r2
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

/// SUBA r, adr, x
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

/// SUBA r1, r2
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

/// SUBL r, adr, x
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
  final result = (v1 + (v2 ^ -1) + 1) & maskBits;
  final flag = _sublFlag(v1, v2);

  r.setGR(gr, result);
  r.FR = flag;
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
