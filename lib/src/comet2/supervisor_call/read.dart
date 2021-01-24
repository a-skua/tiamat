import '../resource.dart' show Resource;
import '../device.dart' show Device;
import '../../util/charcode.dart' show char2code;
import 'util.dart';

void read(final Resource r, final Device d) {
  final gr = r.generalRegisters;
  final ram = r.memory;

  for (var char in d.input().split('')) {
    final pointer = gr[1].value;
    final length = gr[2].value;

    if (length == 0) {
      break;
    }
    gr[2].value -= 1;

    ram[pointer] = char2code[char] ?? 0;
    gr[1].value += 1;
  }

  {
    final length = gr[2].value;
    if (length > 0) {
      final pointer = gr[1].value;
      ram[pointer] = eof;
    }
  }
}
