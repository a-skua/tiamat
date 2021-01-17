import 'register.dart';

/// Flag position bits.
class Flag {
  static const overflow = 1 << 0;
  static const sign = 1 << 1;
  static const zero = 1 << 2;
}

/// COMET2's flag register
class FlagRegister extends Register {
  FlagRegister({
    String name = 'FR',
    int value = 0,
  }) : super(name, value: value, bits: 3);

  /// Get state of overflow.
  bool get overflow => this.value & Flag.overflow > 0;

  /// Set state of overflow.
  void set overflow(bool flag) {
    if (flag) {
      this.value |= Flag.overflow;
    } else {
      this.value &= Flag.overflow ^ -1;
    }
  }

  /// Get state of sign flag.
  bool get sign => this.value & Flag.sign > 0;

  /// Set state of sign flag.
  void set sign(bool flag) {
    if (flag) {
      this.value |= Flag.sign;
    } else {
      this.value &= Flag.sign ^ -1;
    }
  }

  /// Get state of zero flag.
  bool get zero => this.value & Flag.zero > 0;

  /// Set state of zero flag.
  void set zero(bool flag) {
    if (flag) {
      this.value |= Flag.zero;
    } else {
      this.value &= Flag.zero ^ -1;
    }
  }
}
