import '../../core/error.dart';
import 'result.dart';

enum State {
  none,
  error,

  /// |LABEL
  /// |^^^^^ label
  label,

  /// |GR0X
  /// |^^^ register?
  register,
}

/// A seventh automata.
///
/// Syntax: label
Result automata(final List<int> runes) {
  final startLabel = 'A'.runes.first;
  final endLabel = 'Z'.runes.first;
  final startNum = '0'.runes.first;
  final endNum = '9'.runes.first;
  final endNumR = '7'.runes.first;
  final register = 'GR'.runes.toList();

  Error? error = null;
  var state = State.none;
  var pointer = 0;
  for (final rune in runes) {
    switch (state) {
      case State.none:
        // |GRX
        // |^ register?
        if (rune == register[0]) {
          pointer = 1;
          state = State.register;
          break;
        }
        // |LABEL
        // |^
        if (rune >= startLabel && rune <= endLabel) {
          pointer = 1;
          state = State.label;
          break;
        }
        // |12345
        // |^ error!
        // +
        // |#0000
        // |^ error!
        error = Error(
          'label cannot use this char: $rune',
          ErrorType.operand,
        );
        state = State.error;
        break;
      case State.label:
        // |LABEL6789
        // |````````^ error!
        if (pointer == 8) {
          error = Error(
            'label must be within 8 digits',
            ErrorType.operand,
          );
          state = State.error;
          break;
        }
        // |LABEL
        // |```^ label!
        if ((rune >= startLabel && rune <= endLabel) ||
            (rune >= startNum && rune <= endNum)) {
          pointer += 1;
          break;
        }
        // |LABE$
        // |````^ error!
        error = Error(
          'label cannot use this char: $rune',
          ErrorType.operand,
        );
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
          break;
        }
        // |GR0X
        // |```^ label!
        if ((rune >= startLabel && rune <= endLabel) ||
            (rune >= startNum && rune <= endNum)) {
          pointer += 1;
          state = State.label;
          break;
        }
        // |GR0#
        // |```^ error!
        error = Error(
          'label cannot use this char: $rune',
          ErrorType.operand,
        );
        state = State.error;
        break;
      case State.error:
      default:
        return Result([], state, error: error);
    }
  }

  if (state == State.none || state == State.label) {
    return Result([], state);
  }

  // |GR0[EOF]
  // |```^ register!
  if (state == State.register) {
    return Result(
      [],
      state,
      error: Error(
        'label cannot use register\'s name: GR0 - GR7',
        ErrorType.operand,
      ),
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
