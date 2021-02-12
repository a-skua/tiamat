import '../core/symbol.dart';
import '../core/node.dart';
import 'util.dart';

enum _State {
  none,
  address,
  hexAddress,
  error,
}

/// An instruction of CASL2, named DS.
///
/// To ensure word space.
void ds(final Symbol s, final Tree t) {
  final sharp = '#'.runes.first;
  final startNum = '0'.runes.first;
  final endNum = '9'.runes.first;

  var state = _State.none;
  for (final rune in s.operand) {
    switch (state) {
      case _State.none:
        // |12345
        // |^
        if (rune >= startNum && rune <= endNum) {
          state = _State.address;
          break;
        }
        // |#1234
        // |^
        if (rune == sharp) {
          state = _State.hexAddress;
          break;
        }
        // |LABEL
        // |^ error!
        state = _State.error;
        break;
      case _State.address:
      case _State.hexAddress:
        // |12E45
        // |``^ error!
        // +
        // |#00O0
        // |```^ error!
        if (rune < startNum || rune > endNum) {
          state = _State.error;
          break;
        }
        break;
      case _State.error:
      default:
    }
  }

  if (state == _State.hexAddress || state == _State.address) {
    final size =
        int.parse(String.fromCharCodes(s.operand).replaceFirst('#', '0x'));
    assert(size > 0);
    s.nodes.addAll(List.filled(size, Node(0)));
    t.nodes.addAll(s.nodes);
    if (s.label.isNotEmpty) {
      setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
    }
    return;
  }

  assert(state != _State.none);
  assert(state != _State.error);
}
