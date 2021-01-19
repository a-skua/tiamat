import 'memory.dart';
import 'register.dart';
import 'flag.dart';

/// COMET2's resource.
class Resource {
  final Memory memory = Memory();

  /// General Register0 - GR7.
  final List<Register> generalRegisters =
      List.generate(8, (i) => Register('GR$i'));

  /// Stack Pointer
  final Register stackPointer = Register('SP')..value = 0xffff;

  /// Program Register
  final Register programRegister = Register('PR');

  /// Flag Register
  final FlagRegister flagRegister = FlagRegister();

  @deprecated
  int getGR(final int i) =>
      this.generalRegisters[i % this.generalRegisters.length].value;

  @deprecated
  bool setGR(final int i, final int val) {
    this.generalRegisters[i % this.generalRegisters.length].value = val;
    return true;
  }

  @deprecated
  int get SP => this.stackPointer.value;

  @deprecated
  void set SP(final int val) => this.stackPointer.value = val;

  @deprecated
  int get PR => this.programRegister.value;

  @deprecated
  void set PR(final int val) => this.programRegister.value = val;

  @deprecated
  int get FR => this.flagRegister.value;

  @deprecated
  void set FR(final int val) => this.flagRegister.value = val;

  @deprecated
  bool get OF => this.flagRegister.overflow;

  @deprecated
  void set OF(final bool f) => this.flagRegister.overflow = f;

  @deprecated
  bool get SF => this.flagRegister.sign;

  @deprecated
  void set SF(final bool f) => this.flagRegister.sign = f;

  @deprecated
  bool get ZF => this.flagRegister.zero;

  @deprecated
  void set ZF(final bool f) => this.flagRegister.zero = f;
}
