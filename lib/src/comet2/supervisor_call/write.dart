import '../resource.dart' show Resource;
import '../device.dart' show Device;
import 'package:tiamat/src/casl2/charcode.dart' show RealToRune;
import 'util.dart';

Future<void> write(final Resource r, final Device d) async {
  final gr = r.generalRegisters;
  final ram = r.memory;

  final pointer = gr[1].value;
  final length = gr[2].value;
  var str = '';
  for (var i = 0; i < length; i++) {
    final real = ram[pointer + i];
    if (real == eof.toUnsigned(ram.bits)) {
      break;
    }
    final rune = real.rune;
    str += String.fromCharCode(rune);
  }

  d.output(str);
}
