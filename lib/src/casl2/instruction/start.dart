import '../node/node.dart';
import 'util.dart';

enum State {
  none,
  address,
  hexAddress,
  label,
  error,
}

/// An instruction casl2, named START.
///
/// Start is JUMP to address when has operand.
/// Other than that do nothing.
/// This label must not empty.
void start(final Root r, final Tree t) {
  final sharp = '#'.runes.first;
  final startNum = '0'.runes.first;
  final endNum = '9'.runes.first;

  assert(r.label.isNotEmpty);
  t.startLabel = r.label;

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
        // |#0000
        // |^
        if (rune == sharp) {
          state = State.hexAddress;
          break;
        }
        // |LABEL
        // |^
        state = State.label;
        break;
      case State.address:
      case State.hexAddress:
        // |12E45
        // |``^
        // +
        // |#00O0
        // |```^
        if (rune < startNum || rune > endNum) {
          state = State.error;
          break;
        }
        break;
      case State.label:
        // TODO:
        // |LABEL++
        // |`````^ error
        break;
      case State.error:
      default:
    }
  }

  if (state == State.none) {
    return;
  }

  if (state == State.label) {
    // Translate: JUMP LABEL
    r.nodes.addAll([
      Node(0x6400),
      Node(0, Type.label),
    ]);
    t.nodes.addAll(r.nodes);
    addReferenceLabel(r.operand, r.nodes.first, t.labels);
    return;
  }

  if (state == State.hexAddress) {
    // Translate: JUMP adr
    r.nodes.addAll([
      Node(0x6400),
      Node(int.parse(r.operand.replaceFirst('#', '0x'))),
    ]);
    t.nodes.addAll(r.nodes);
    return;
  }

  if (state == State.address) {
    // Translate: JUMP adr
    r.nodes.addAll([
      Node(0x6400),
      Node(int.parse(r.operand)),
    ]);
    t.nodes.addAll(r.nodes);
    return;
  }

  // TODO: throw error ?
  assert(state != State.error);
}
