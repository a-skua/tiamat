import '../resource.dart' show Resource;
import '../device.dart' show Device;
import 'package:tiamat/src/casl2/charcode.dart' show RuneToReal;
import 'util.dart';

Future<void> read(final Resource r, final Device d) async {
  final gr = r.generalRegisters;
  final ram = r.memory;

  final pointer = gr[1];
  final length = gr[2];

  final input = await d.input();
  for (var rune in input.runes) {
    if (length.value == 0) {
      break;
    }
    length.value -= 1;

    ram[pointer.value] = rune.real;
    pointer.value += 1;
  }

  if (length.value > 0) {
    ram[pointer.value] = eof;
  }
}
