import '../../core/error.dart';
import '../../core/node.dart';
import 'result.dart';

enum State {
  none,
  error,

  /// |123
  /// |^^^ address
  address,
}

/// A sixth automata.
///
/// Expect a numeric of decimal.
Result automata(final List<int> runes) {
  final one = '1'.runes.first;
  final startNum = '0'.runes.first;
  final endNum = '9'.runes.first;

  var state = State.none;
  Error? error = null;
  for (final rune in runes) {
    switch (state) {
      case State.none:
        // |12345
        // |^
        if (rune >= one && rune <= endNum) {
          // num > 0
          // TODO: num >= 0
          state = State.address;
          break;
        }
        // |#1234
        // |^ error!
        // +
        // |LABEL
        // |^ error!
        error = Error(
          'must be used only decimal.',
          ErrorType.operand,
        );
        state = State.error;
        break;
      case State.address:
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
        return Result([], state, error: error);
    }
  }

  if (state == State.address) {
    final size = int.parse(String.fromCharCodes(runes));
    return Result(
      List.filled(size, Node(0)),
      state,
    );
  }
  return Result(
    [],
    state,
    error: Error(
      'syntax error',
      ErrorType.operand,
    ),
  );
}
