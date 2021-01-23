import 'memory.dart';
import 'register.dart';
import 'flag.dart';

/// COMET2's resource.
class Resource {
  final Memory memory = Memory();

  /// General Register 0 - 7.
  final List<Register> generalRegisters =
      List.generate(8, (i) => Register('GR$i'));

  /// Stack Pointer
  final Register stackPointer = Register('SP')..value = 0xffff;

  /// Program Register
  final Register programRegister = Register('PR');

  /// Flag Register
  final FlagRegister flagRegister = FlagRegister();

  /// Deprecated: will be deleted the next mejor version.
  ///
  /// Proposal:
  /// ```
  /// final r = Resource();
  /// final gr = r.generalRegisters;
  /// final value = gr[0].value;
  /// ```
  @deprecated
  int getGR(final int i) =>
      this.generalRegisters[i % this.generalRegisters.length].value;

  /// Deprecated: will be deleted the next mejor version.
  ///
  /// Proposal:
  /// ```
  /// final r = Resource();
  /// final gr = r.generalRegisters;
  /// gr[0].value = 0x4444;
  /// ```
  @deprecated
  bool setGR(final int i, final int val) {
    this.generalRegisters[i % this.generalRegisters.length].value = val;
    return true;
  }

  /// Deprecated: will be deleted the next mejor version.
  ///
  /// Proposal:
  /// ```
  /// final r = Resource();
  /// final sp = r.stackPointer;
  /// final value = sp.value;
  /// ```
  @deprecated
  int get SP => this.stackPointer.value;

  /// Deprecated: will be deleted the next mejor version.
  ///
  /// Proposal:
  /// ```
  /// final r = Resource();
  /// final sp = r.stackPointer;
  /// sp.value = 0xffff;
  /// ```
  @deprecated
  void set SP(final int val) => this.stackPointer.value = val;

  /// Deprecated: will be deleted the next major version.
  ///
  /// Proposal:
  /// ```
  /// final r = Resource();
  /// final pr = r.programRegister;
  /// final value = pr.value;
  /// ```
  @deprecated
  int get PR => this.programRegister.value;

  /// Deprecated: will be deleted the next mejor version.
  ///
  /// Proposal:
  /// ```
  /// final r = Resource();
  /// final pr = r.programRegister;
  /// pr.value = 0x6000;
  /// ```
  @deprecated
  void set PR(final int val) => this.programRegister.value = val;

  /// Deprecated: will be deleted the next mejor version.
  ///
  /// Proposal:
  /// ```
  /// final r = Resource();
  /// final fr = r.flagRegister;
  /// final value = fr.value;
  /// ```
  @deprecated
  int get FR => this.flagRegister.value;

  /// Deprecated: will be deleted the next mejor version.
  ///
  /// Proposal:
  /// ```
  /// final r = Resource();
  /// final fr = r.flagRegister;
  /// fr.value = Flag.zero | Flag.sign;
  /// ```
  @deprecated
  void set FR(final int val) => this.flagRegister.value = val;

  /// Deprecated: will be deleted the next mejor version.
  ///
  /// Proposal: to used `isOverflow` or `isNotOverflow`
  /// ```
  /// final r = Resource();
  /// final fr = r.flagRegister;
  /// if (fr.isOverflow) {
  ///   // any...
  /// }
  /// ```
  @deprecated
  bool get OF => this.flagRegister.isOverflow;

  /// Deprecated: will be deleted the next mejor version.
  ///
  /// Proposal: to used `isSign` or `isNotSign`
  /// ```
  /// final r = Resource();
  /// final fr = r.flagRegister;
  /// if (fr.isSign) {
  ///   // any...
  /// }
  /// ```
  @deprecated
  bool get SF => this.flagRegister.isSign;

  /// Deprecated: will be deleted the next mejor version.
  ///
  /// Proposal: to used `isZero` or `isNotZero`
  /// ```
  /// final r = Resource();
  /// final fr = r.flagRegister;
  /// if (fr.isZero) {
  ///   // any...
  /// }
  /// ```
  @deprecated
  bool get ZF => this.flagRegister.isZero;

  /// Deprecated: will be deleted the next mejor version.
  ///
  /// Proposal:
  /// ```
  /// final r = Resource();
  /// final fr = r.flagRegister;
  /// // true
  /// fr.value |= Flag.overflow;
  /// // false
  /// fr.value &= Flag.overflow ^ -1;
  /// ```
  @deprecated
  void set OF(final bool f) {
    final fr = this.flagRegister;

    if (f) {
      fr.value |= Flag.overflow;
    } else {
      fr.value &= Flag.overflow ^ -1;
    }
  }

  /// Deprecated: will be deleted the next mejor version.
  ///
  /// Proposal:
  /// ```
  /// final r = Resource();
  /// final fr = r.flagRegister;
  /// // true
  /// fr.value |= Flag.sign;
  /// // false
  /// fr.value &= Flag.sign ^ -1;
  /// ```
  @deprecated
  void set SF(final bool f) {
    final fr = this.flagRegister;

    if (f) {
      fr.value |= Flag.sign;
    } else {
      fr.value &= Flag.sign ^ -1;
    }
  }

  /// Deprecated: will be deleted the next mejor version.
  ///
  /// Proposal:
  /// ```
  /// final r = Resource();
  /// final fr = r.flagRegister;
  /// // true
  /// fr.value |= Flag.zero;
  /// // false
  /// fr.value &= Flag.zero ^ -1;
  /// ```
  @deprecated
  void set ZF(final bool f) {
    final fr = this.flagRegister;

    if (f) {
      fr.value |= Flag.zero;
    } else {
      fr.value &= Flag.zero ^ -1;
    }
  }
}
