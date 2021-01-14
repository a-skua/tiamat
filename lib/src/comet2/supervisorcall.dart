import '../resource/resource.dart';
import '../util/charcode.dart';

const eof = 0xffff;
typedef Read = String Function();
typedef Write = void Function(String s);

class Supervisor {
  Read read = () => '';
  Write write = (s) {
    print(s);
  };

  void call(final Resource r, final int i) {
    switch (i) {
      case 1:
        _read(r, this.read);
        break;
      case 2:
        _write(r, this.write);
        break;
    }
  }
}

void _read(final Resource r, final Read read) {
  for (var c in read().split('')) {
    final len = r.getGR(2);
    if (len == 0) {
      break;
    }
    r.setGR(2, len - 1);
    final p = r.getGR(1);
    r.memory.setWord(p, char2code[c] ?? 0);
    r.setGR(1, p + 1);
  }
  final len = r.getGR(2);
  if (len > 0) {
    final p = r.getGR(1);
    r.memory.setWord(p, eof);
  }
}

void _write(final Resource r, final Write write) {
  var s = '';
  final p = r.getGR(1);
  for (var i = 0; i < r.getGR(2); i++) {
    final c = r.memory.getWord(p + i);
    if (c == eof) {
      break;
    }
    s += code2char[c] ?? '';
  }
  write(s);
}
