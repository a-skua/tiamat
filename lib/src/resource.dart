const MEMORY_SIZE = 2 << 16;
const GR_SIZE = 8;
const OVERFLOW_FLAG = 1 << 0;
const SIGN_FLAG = 1 << 1;
const ZERO_FLAG = 1 << 2;

class Resource {
  List<int> _memories;
  List<int> _general_registers;
  int _stack_pointer;
  int _program_register;
  int _flag_register;
  Resource() {
    this._memories = List(MEMORY_SIZE);
    this._general_registers = List(GR_SIZE);
    this._stack_pointer = MEMORY_SIZE - 1;
    this._program_register = 0;
    this._flag_register = 0;
  }

  int getGR(int i) {
    return i < this._general_registers.length ? this._general_registers[i] : 0;
  }

  bool setGR(int i, int val) {
    if (i < this._general_registers.length) {
      this._general_registers[i] = val;
      return true;
    }
    return false;
  }

  int get SP => this._stack_pointer;
  set SP(int val) => this._stack_pointer = val;

  int get PR => this._program_register;
  set PR(int val) => this._program_register = val;

  int get FR => this._flag_register;
  set FR(int val) => this._flag_register;

  bool get OF => this._flag_register & OVERFLOW_FLAG > 0;
  set OF(bool f) {
    if (f) {
      this._flag_register |= OVERFLOW_FLAG;
    } else {
      this._flag_register &= (OVERFLOW_FLAG ^ -1);
    }
  }

  bool get SF => this._flag_register & SIGN_FLAG > 0;
  set SF(bool f) {
    if (f) {
      this._flag_register |= SIGN_FLAG;
    } else {
      this._flag_register &= (SIGN_FLAG ^ -1);
    }
  }

  bool get ZF => this._flag_register & ZERO_FLAG > 0;
  set ZF(bool f) {
    if (f) {
      this._flag_register |= ZERO_FLAG;
    } else {
      this._flag_register &= (ZERO_FLAG ^ -1);
    }
  }
}
