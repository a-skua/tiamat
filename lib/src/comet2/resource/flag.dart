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
  }) : super(name, bits: 3);

  /// Get state of overflow flag.
  bool get isOverflow => this.value & Flag.overflow > 0;

  /// Get state of sign flag.
  bool get isSign => this.value & Flag.sign > 0;

  /// Get state of zero flag.
  bool get isZero => this.value & Flag.zero > 0;

  /// Get state of overflow flag.
  bool get isNotOverflow => !this.isOverflow;

  /// Get state of sign flag.
  bool get isNotSign => !this.isSign;

  /// Get state of zero flag.
  bool get isNotZero => !this.isZero;
}
