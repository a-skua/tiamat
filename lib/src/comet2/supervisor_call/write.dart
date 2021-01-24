import '../resource.dart' show Resource;
import '../device.dart' show Device;
import '../../util/charcode.dart' show code2char;
import 'util.dart';

void write(final Resource r, final Device d) {
  final gr = r.generalRegisters;
  final ram = r.memory;

  final pointer = gr[1].value;
  final length = gr[2].value;
  var s = '';
  for (var i = 0; i < length; i++) {
    final char = ram[pointer + i];
    if (char == eof.toUnsigned(ram.bits)) {
      break;
    }
    s += code2char[char] ?? '□';
  }

  d.output(s);
}
