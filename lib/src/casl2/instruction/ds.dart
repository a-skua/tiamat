import '../node/node.dart';
import 'util.dart';

enum State {
  none,
  address,
  hexAddress,
  error,
}

/// An instruction of casl2, named DS.
///
/// To ensure word space.
void ds(final Root r, final Tree t) {
  final sharp = '#'.runes.first;
  final startNum = '0'.runes.first;
  final endNum = '9'.runes.first;

  var state = State.none;
  for (final rune in r.operand.runes) {
    switch (state) {
      case State.none:
        // |12345
        // |^
        if (rune >= startNum && rune <= endNum) {
          state = State.address;
          break;
        }
        // |#1234
        // |^
        if (rune == sharp) {
          state = State.hexAddress;
          break;
        }
        // |LABEL
        // |^ error!
        state = State.error;
        break;
      case State.address:
      case State.hexAddress:
        // |12E45
        // |``^ error!
        // +
        // |#00O0
        // |```^ error!
        if (rune < startNum || rune > endNum) {
          state = State.error;
          break;
        }
        break;
      case State.error:
      default:
    }
  }

  if (state == State.hexAddress || state == State.address) {
    final size = int.parse(r.operand.replaceFirst('#', '0x'));
    assert(size > 0);
    r.nodes.addAll(List.filled(size, Node(0)));
    t.nodes.addAll(r.nodes);
    if (r.label.isNotEmpty) {
      setLabel(r.label, t.nodes.first, t.labels);
    }
    return;
  }

  assert(state != State.none);
  assert(state != State.error);
}
