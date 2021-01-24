import '../resource.dart' show Resource;
import '../device.dart' show Device;
import '../../util/charcode.dart' show char2code;
import 'util.dart';

void read(final Resource r, final Device d) {
  final gr = r.generalRegisters;
  final ram = r.memory;

  final pointer = gr[1];
  final length = gr[2];

  for (var char in d.input().split('')) {
    if (length.value == 0) {
      break;
    }
    length.value -= 1;

    ram[pointer.value] = char2code[char] ?? 0;
    pointer.value += 1;
  }

  if (length.value > 0) {
    ram[pointer.value] = eof;
  }
}
