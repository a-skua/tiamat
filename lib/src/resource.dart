const wordSize = 16;
const memorySize = 1 << 16;
const generalRegisterSize = 8;
const overflowFlag = 1 << 0;
const signFlag = 1 << 1;
const zeroFlag = 1 << 2;

class Memory {
  final _size = memorySize;
  final List<int> _values = List.filled((memorySize ~/ 2) + 1, 0);

  int get size => this._size;

  bool _isWithin(final int addr) {
    if (addr >= 0 && addr < this._size) {
      return true;
    }
    return false;
  }

  int getWord(final int addr) {
    if (!this._isWithin(addr)) {
      return 0;
    }

    const int maskBits = (1 << wordSize) - 1;
    final i = addr ~/ 2;
    if (addr % 2 > 0) {
      return (this._values[i] >> wordSize) & maskBits;
    } else {
      return this._values[i] & maskBits;
    }
  }

  bool setWord(final int addr, final int value) {
    if (!this._isWithin(addr)) {
      return false;
    }

    const int maskBits = (1 << wordSize) - 1;
    final i = addr ~/ 2;
    if (addr % 2 > 0) {
      this._values[i] &= maskBits;
      this._values[i] |= (value & maskBits) << wordSize;
    } else {
      this._values[i] &= maskBits << wordSize;
      this._values[i] |= value & maskBits;
    }
    return true;
  }
}

class Resource {
  final Memory _memory = Memory();
  final List<int> _generalRegisters = List.filled(generalRegisterSize, 0);
  int _stackPointer = 0;
  int _programRegister = 0;
  int _flagRegister = 0;

  int getGR(final int i) {
    if (i >= 0 && i < this._generalRegisters.length) {
      return this._generalRegisters[i];
    }
    return 0;
  }

  bool setGR(final int i, final int val) {
    if (i >= 0 && i < this._generalRegisters.length) {
      this._generalRegisters[i] = val & ((1 << wordSize) - 1);
      return true;
    }
    return false;
  }

  int get SP => this._stackPointer;
  set SP(final int val) => this._stackPointer = val & ((1 << wordSize) - 1);

  int get PR => this._programRegister;
  set PR(final int val) => this._programRegister = val & ((1 << wordSize) - 1);

  int get FR => this._flagRegister;
  set FR(final int val) => this._flagRegister = val & ((1 << 3) - 1);

  bool get OF => this._flagRegister & overflowFlag > 0;
  set OF(final bool f) {
    if (f) {
      this._flagRegister |= overflowFlag;
    } else {
      this._flagRegister &= (overflowFlag ^ -1);
    }
  }

  bool get SF => this._flagRegister & signFlag > 0;
  set SF(final bool f) {
    if (f) {
      this._flagRegister |= signFlag;
    } else {
      this._flagRegister &= (signFlag ^ -1);
    }
  }

  bool get ZF => this._flagRegister & zeroFlag > 0;
  set ZF(final bool f) {
    if (f) {
      this._flagRegister |= zeroFlag;
    } else {
      this._flagRegister &= (zeroFlag ^ -1);
    }
  }

  Memory get memory => this._memory;
}
