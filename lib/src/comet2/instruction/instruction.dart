import '../../resource/resource.dart';
import '../../resource/flag.dart';
import '../supervisorcall.dart';

export 'no_operation.dart';

export 'load.dart';
export 'store.dart';
export 'load_address.dart';

export 'add_arithmetic.dart';
export 'add_logical.dart';
export 'subtract_arithmetic.dart';
export 'subtract_logical.dart';

export 'and.dart';
export 'or.dart';
export 'exclusive_or.dart';

export 'compare_arithmetic.dart';
export 'compare_logical.dart';

export 'shift_left_arithmetic.dart';
export 'shift_right_arithmetic.dart';
export 'shift_left_logical.dart';
export 'shift_right_logical.dart';

typedef Instruction = void Function(Resource r);

const wordSize = 16;
const overflowFlag = Flag.overflow;
const signFlag = Flag.sign;
const zeroFlag = Flag.zero;

/// JUMP adr,x
void unconditionalJump(final Resource r) {
  final x = r.memory[r.PR] & 0xf;
  r.PR += 1;

  final adr = _getADR(r, x);

  r.PR = adr;
}

/// JPL adr,x
void jumpOnPlus(final Resource r) {
  final x = r.memory[r.PR] & 0xf;
  r.PR += 1;

  final adr = _getADR(r, x);

  if (!r.SF && !r.ZF) {
    r.PR = adr;
  }
}

/// JMI adr,x
void jumpOnMinus(final Resource r) {
  final x = r.memory[r.PR] & 0xf;
  r.PR += 1;

  final adr = _getADR(r, x);

  if (r.SF) {
    r.PR = adr;
  }
}

/// JNZ adr,x
void jumpOnNonZero(final Resource r) {
  final x = r.memory[r.PR] & 0xf;
  r.PR += 1;

  final adr = _getADR(r, x);

  if (!r.ZF) {
    r.PR = adr;
  }
}

/// JZE adr,x
void jumpOnZero(final Resource r) {
  final x = r.memory[r.PR] & 0xf;
  r.PR += 1;

  final adr = _getADR(r, x);

  if (r.ZF) {
    r.PR = adr;
  }
}

/// JOV adr,x
void jumpOnOverflow(final Resource r) {
  final x = r.memory[r.PR] & 0xf;
  r.PR += 1;

  final adr = _getADR(r, x);

  if (r.OF) {
    r.PR = adr;
  }
}

/// PUSH adr,x
void push(final Resource r) {
  final x = r.memory[r.PR] & 0xf;
  r.PR += 1;

  final adr = _getADR(r, x);

  r.SP -= 1;
  r.memory[r.SP] = adr;
}

/// POP r
void pop(final Resource r) {
  final cache = r.memory[r.PR];
  r.PR += 1;

  final gr = (cache >> 4) & 0xf;
  final v = r.memory[r.SP];
  r.SP += 1;

  r.setGR(gr, v);
}

/// CALL adr,x
void callSubroutine(final Resource r) {
  final x = r.memory[r.PR] & 0xf;
  r.PR += 1;

  final adr = _getADR(r, x);

  r.SP -= 1;
  r.memory[r.SP] = r.PR;
  r.PR = adr;
}

/// RET
void returnFromSubroutine(final Resource r) {
  r.PR = r.memory[r.SP];
  r.SP += 1;
}

/// SVC adr,x
void supervisorCall(final Resource r, Supervisor s) {
  final x = r.memory[r.PR] & 0xf;
  r.PR += 1;

  final adr = _getADR(r, x);

  s.call(r, adr);
}

int _getADR(final Resource r, final int x) {
  final adr = x == 0 ? r.memory[r.PR] : (r.memory[r.PR] + r.getGR(x)) & 0xffff;
  r.PR += 1;
  return adr;
}

int _complement2(final int v) {
  const maskBits = (1 << wordSize) - 1;
  return ((v ^ -1) + 1) & maskBits;
}

int _andFlag(final int result) {
  if ((result & (1 << (wordSize - 1))) > 0) {
    return signFlag;
  }
  if (result == 0) {
    return zeroFlag;
  }
  return 0;
}

int _shiftFlag(final int v, final int of) {
  const signMask = 1 << (wordSize - 1);
  var flag = 0;

  if (of > 0) {
    flag |= overflowFlag;
  }
  if ((v & signMask) > 0) {
    flag |= signFlag;
  } else if (v == 0) {
    flag |= zeroFlag;
  }

  return flag;
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
  } else if (result == 0) {
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
  } else if (result == 0) {
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
  } else if (result == 0) {
    flag |= zeroFlag;
  }
  return flag;
}

int _cpaFlag(final int v1, final int v2) {
  if (v1 == v2) {
    return zeroFlag;
  }

  const signMask = 0x8000;
  if ((v1 & signMask == 0 && v2 & signMask == 0) ||
      (v1 & signMask > 0 && v2 & signMask > 0)) {
    if (v1 > v2) {
      return 0;
    } else {
      return signFlag;
    }
  } else if (v1 & signMask > 0 && v2 & signMask == 0) {
    return signFlag;
  } else {
    // v1 & signMask == 0 && v2 & signMask > 0
    return 0;
  }
}

int _cplFlag(final int v1, final int v2) {
  if (v1 > v2) {
    return 0;
  }

  if (v1 == v2) {
    return zeroFlag;
  }

  // v1 < v2
  return signFlag;
}
