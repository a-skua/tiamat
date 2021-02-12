import '../../core/node.dart';
import 'result.dart';

enum State {
  none,
  error,

  /// |r
  /// |^ register!
  register,
}

/// An automata of third pattern.
///
/// Expect one of the result.
/// Correct syntax: r
/// The [high] defines the high order bits
/// with low order padded with zeros.
/// Example:
/// ```
/// final result = automata(operand, 0x1200);
/// ```
Result automata(final List<int> runes, final int high) {
  final startNum = '0'.runes.first;
  final endNumR = '7'.runes.first;
  final register = 'GR'.runes.toList();

  var pointer = 0;
  var low = 0;

  var state = State.none;
  for (final rune in runes) {
    switch (state) {
      case State.none:
        // |GR0X,GR1
        // |^ register?
        if (rune == register[0]) {
          pointer = 1;
          state = State.register;
          break;
        }
        // |label
        // |^ error!
        state = State.error;
        break;
      case State.register:
        // |GR0X
        // |`^ register?
        if (pointer == 1 && rune == register[1]) {
          pointer = 2;
          break;
        }
        // |GR0X
        // |``^ register?
        if (pointer == 2 && rune >= startNum && rune <= endNumR) {
          pointer = 3;
          low = int.parse(String.fromCharCode(rune)) << 4;
          break;
        }
        // |GR0,#FF13
        // |```^ error!
        // +
        // |GR#
        // |``^
        state = State.error;
        break;
      case State.error:
      default:
        break;
    }
  }

  // |GR0[EOF]
  // |```^ register!
  if (pointer == 3 && state == State.register) {
    return Result([Node(high | low)], State.register);
  }

  return Result([], state, error: Error());
}
