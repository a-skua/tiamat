import '../resource.dart' show Resource;
import '../device.dart' show Device;
import 'package:tiamat/src/charcode/charcode.dart';
import 'util.dart';

Future<void> write(final Resource r, final Device d) async {
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
    final rune = codeAsRune(char);
    if (rune != null) {
      s += String.fromCharCode(rune);
    } else {
      s += '*';
    }
  }

  d.output(s);
}
