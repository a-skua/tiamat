import 'package:tiamat/typedef.dart';
import 'package:tiamat/casl2.dart' show Real;
import './resource/device.dart' as device;

/// Flag position bits.
final class Flag {
  static const zero = 0x0001;
  static const sign = 0x0002;
  static const overflow = 0x0004;
}

typedef GR = int;

extension ToSigned on Real {
  int get signed => toSigned(16);
}

extension ToUnsigned on Real {
  int get unsigned => toUnsigned(16);
}

final class Resource {
  final List<Real> memory = List.filled(0x10000, 0, growable: false);

  /// General Register
  final List<GR> gr = List.filled(8, 0, growable: false);

  /// Program Counter
  Real sp = 0xffff;
  Real pr = 0;
  Real fr = 0;

  Resource();

  bool get zf => fr & Flag.zero != 0;
  set zf(final bool isZero) {
    if (isZero) {
      fr |= Flag.zero;
    } else {
      fr &= Flag.zero ^ 0xffff;
    }
  }

  bool get sf => fr & Flag.sign != 0;
  set sf(final bool isSign) {
    if (isSign) {
      fr |= Flag.sign;
    } else {
      fr &= Flag.sign ^ 0xffff;
    }
  }

  bool get of => fr & Flag.overflow != 0;
  set of(final bool isOverflow) {
    if (isOverflow) {
      fr |= Flag.overflow;
    } else {
      fr &= Flag.overflow ^ 0xffff;
    }
  }

  @override
  String toString() {
    final gr = this
        .gr
        .map((e) => e.toRadixString(16).toUpperCase().padLeft(4, '0'))
        .toList();
    final pr = this.pr.toRadixString(16).toUpperCase().padLeft(4, '0');
    final sp = this.sp.toRadixString(16).toUpperCase().padLeft(4, '0');
    final zf = this.zf ? '1' : '0';
    final sf = this.sf ? '1' : '0';
    final of = this.of ? '1' : '0';
    return ''
        'GR [0:${gr[0]}, 1:${gr[1]}, 2:${gr[2]}, 3:${gr[3]}, 4:${gr[4]}, 5:${gr[5]}, 6:${gr[6]}, 7:${gr[7]}]\n'
        'PR [$pr]\n'
        'SP [$sp]\n'
        'FR [ZF:$zf, SF:$sf, OF:$of]';
  }
}

final class DeviceError extends Error {
  final String message;
  DeviceError(this.message) : super();

  @override
  String toString() => 'DeviceError: $message';
}

abstract class Device {
  /// [len] is the number of bytes to read.
  Future<Result<String, DeviceError>> read(int len);

  /// [str] is the bytes to write.
  Future<Result<void, DeviceError>> write(String str);

  factory Device() => device.Default();
}
