import '../../core/error.dart';
import '../../core/node.dart';
import 'result.dart';

enum State {
  none,
  error,

  /// |adr,len
  /// |   ^ unstable
  unstable,

  /// |adr,len
  /// |^^^ address|hex address|label
  address,
  hexAddress,
  label,
  register,

  /// |adr,len
  /// |    ^^^ length|hex length
  length,
  hexLength,
}

class ExResult extends Result {
  final String? label;
  final int? address;
  final int length;
  ExResult(
    State lastState, {
    required this.length,
    this.label = null,
    this.address = null,
    Error? error = null,
    List<Node> values = const [],
  }) : super(values, lastState, error: error);

  bool get hasLabel => this.label != null;
  bool get hasAddress => this.address != null;
}

/// An automata of fourth pattern.
///
/// Expect one of the result.
/// Correct syntax: adr,len
/// Example:
/// ```
/// final result = automata(operand);
/// ```
ExResult automata(final List<int> runes) {
  final sharp = '#'.runes.first;
  final comma = ','.runes.first;
  final startNum = '0'.runes.first;
  final endNum = '9'.runes.first;
  final startHex = 'A'.runes.first;
  final endHex = 'F'.runes.first;
  final endNumR = '7'.runes.first;
  final startLabel = 'A'.runes.first;
  final endLabel = 'Z'.runes.first;
  final register = 'GR'.runes.toList();

  final temporary = <int>[];
  var pointer = 0;
  var length = 0;
  int? address = null;
  String? label = null;

  var state = State.none;
  for (final rune in runes) {
    switch (state) {
      case State.none:
        // |GR0X,255
        // |^ register?
        if (rune == register[0]) {
          temporary.add(rune);
          pointer = 1;
          state = State.register;
          break;
        }
        // |#FF13,255
        // |^ hex address!
        if (rune == sharp) {
          pointer = 0;
          state = State.hexAddress;
          break;
        }
        // |123,456
        // |^ address!
        if (rune >= startNum && rune <= endNum) {
          temporary.add(rune);
          pointer = 1;
          state = State.address;
          break;
        }
        // |LABEL,255
        // |^ label!
        if (rune >= startLabel && rune <= endLabel) {
          temporary.add(rune);
          pointer = 1;
          state = State.label;
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
          break;
        }
        // |GR0,#FF13
        // |```^ error!
        // +
        // |GR#
        // |``^
        state = State.error;
        break;
      case State.address:
        // |1234,255
        // |``^ address!
        if (rune >= startNum && rune <= endNum) {
          temporary.add(rune);
          break;
        }
        // |1234,255
        // |````^ delimiter!
        if (rune == comma) {
          address = int.parse(String.fromCharCodes(temporary));
          temporary.clear();
          pointer = 0;
          state = State.unstable;
          break;
        }
        // |12#4,255
        // |``^ error!
        state = State.error;
        break;
      case State.hexAddress:
        // |#FF13,255
        // |```^ hex address!
        if (pointer < 4 && (rune >= startNum && rune <= endNum) ||
            (rune >= startHex && rune <= endHex)) {
          temporary.add(rune);
          pointer += 1;
          break;
        }
        // |#FF13,255
        // |`````^ delimiter!
        if (pointer == 4 && rune == comma) {
          address = int.parse(
            String.fromCharCodes(temporary),
            radix: 16,
          );
          temporary.clear();
          pointer = 0;
          state = State.unstable;
          break;
        }
        // |#FF#0,255
        // |```^ error!
        // +
        // |#FFFF0,255
        // |`````^ error!
        state = State.error;
        break;
      case State.label:
        // |LABEL,255
        // |````^ label!
        if (pointer < 8 && (rune >= startNum && rune <= endNum) ||
            (rune >= startLabel && rune <= endLabel)) {
          temporary.add(rune);
          pointer += 1;
          break;
        }
        // |LABEL,255
        // |`````^ delimiter!
        if (rune == comma) {
          label = String.fromCharCodes(temporary);
          temporary.clear();
          pointer = 0;
          state = State.unstable;
          break;
        }
        // |LaBeL,255
        // |`^ error!
        // +
        // |FF3456789,255
        // |````````^ error!
        state = State.error;
        break;
      case State.length:
        // |LABEL,1234
        // |```````^ length
        if (rune >= startNum && rune <= endNum) {
          temporary.add(rune);
          break;
        }
        // |LABEL,1O0
        // |```````^ error!
        state = State.error;
        break;
      case State.hexLength:
        // |LABEL,#FF14
        // |``````````^ hex length!
        if (pointer < 4 && (rune >= startNum && rune <= endNum) ||
            (rune >= startHex && rune <= endHex)) {
          temporary.add(rune);
          pointer += 1;
          break;
        }
        // |LABEL,#FF#0
        // |`````````^ error!
        // +
        // |LABEL,#FF13II
        // |```````````^ error!
        state = State.error;
        break;
      case State.unstable:
        // |LABEL,#00FF
        // |``````^ hex length!
        if (rune == sharp) {
          pointer = 0;
          state = State.hexLength;
          break;
        }
        // |LABEL,255
        // |``````^ length!
        if (rune >= startNum && rune <= endNum) {
          temporary.add(rune);
          pointer = 1;
          state = State.length;
          break;
        }
        // |LABEL,LABEL
        // |``````^ error!
        state = State.error;
        break;
      case State.error:
      default:
        break;
    }
  }

  // |LABEL,#00FF[EOF]
  // |```````````^ hex length!
  // +
  // |#0001,#00FF[EOF]
  // |```````````^ hex length!
  if (pointer == 4 && state == State.hexLength) {
    final length = int.parse(String.fromCharCodes(temporary), radix: 16);
    if (address != null) {
      return ExResult(state, length: length, address: address);
    } else {
      return ExResult(state, length: length, label: label);
    }
  }

  // |LABEL,255[EOF]
  // |`````````^ length!
  // +
  // |#0001,255[EOF]
  // |`````````^ length!
  if (state == State.length) {
    final length = int.parse(String.fromCharCodes(temporary));
    if (address != null) {
      return ExResult(state, length: length, address: address);
    } else {
      return ExResult(state, length: length, label: label);
    }
  }

  return ExResult(state, length: 0, error: Error('todo', ErrorType.syntax));
}
