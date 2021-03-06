import '../../core/error.dart';
import '../../core/node.dart';
import 'result.dart';

enum State {
  none,
  error,

  /// |adr,x
  /// |^^^ address|hex address|label
  address,
  hexAddress,
  label,
  register,

  /// |adr,x
  /// |    ^ index register
  indexRegister,
}

class ExResult extends Result {
  final String label;
  ExResult(
    List<Node> values,
    State lastState, {
    Error? error = null,
    this.label = '',
  }) : super(values, lastState, error: error);
}

/// An automata of second pattern.
///
/// Expect one of the result.
/// Correct syntax: adr,x
/// The [high] defines the high order bits
/// with low order padded with zeros.
/// Example:
/// ```
/// final result = automata(operand, 0x1200);
/// ```
ExResult automata(final List<int> runes, final int high) {
  final sharp = '#'.runes.first;
  final comma = ','.runes.first;
  final startNum = '0'.runes.first;
  final endNum = '9'.runes.first;
  final startHex = 'A'.runes.first;
  final endHex = 'F'.runes.first;
  final startNumX = '1'.runes.first;
  final endNumR = '7'.runes.first;
  final startLabel = 'A'.runes.first;
  final endLabel = 'Z'.runes.first;
  final register = 'GR'.runes.toList();

  final temporary = <int>[];
  var pointer = 0;
  var low = 0;
  int? address = null;
  String? label = null;
  Error? error = null;

  var state = State.none;
  for (final rune in runes) {
    switch (state) {
      case State.none:
        // |#ABCD
        // |^ hex address!
        if (rune == sharp) {
          pointer = 0;
          state = State.hexAddress;
          break;
        }
        // |123,GR7
        // |^ address!
        if (rune >= startNum && rune <= endNum) {
          pointer = 1;
          temporary.add(rune);
          state = State.address;
          break;
        }
        // |GR0X,GR1
        // |^ register?
        if (rune == register[0]) {
          temporary.add(rune);
          pointer = 1;
          state = State.register;
          break;
        }
        // |LABEL,GR1
        // |^ label
        if (rune >= startLabel && rune <= endLabel) {
          temporary.add(rune);
          pointer = 1;
          state = State.label;
          break;
        }
        // |label
        // |^ error!
        error = Error(
          'cannot be used this character: '
          '${String.fromCharCode(rune)}',
          ErrorType.operand,
        );
        state = State.error;
        break;
      case State.register:
        // |GR0X
        // |`^ register?
        if (pointer == 1 && rune == register[1]) {
          pointer = 2;
          temporary.add(rune);
          break;
        }
        // |GR0X
        // |``^ register?
        if (pointer == 2 && rune >= startNum && rune <= endNumR) {
          pointer = 3;
          temporary.add(rune);
          break;
        }
        // |GR0,GR1
        // |```^ error!
        if (pointer == 3 && rune == comma) {
          error = Error(
            'label cannot be used register\'s name GR0 ~ GR1',
            ErrorType.operand,
          );
          state = State.error;
          break;
        }
        // |G,GR1
        // |`^ delimiter!
        if (rune == comma) {
          label = String.fromCharCodes(temporary);
          temporary.clear();
          pointer = 0;
          state = State.indexRegister;
          break;
        }
        // |GX0
        // |`^ label!
        // +
        // |GR0X
        // |```^ label!
        if ((rune >= startLabel && rune <= endLabel) ||
            (rune >= startNum && rune <= endNum)) {
          pointer += 1;
          temporary.add(rune);
          state = State.label;
          break;
        }
        // |GR#
        // |``^
        error = Error(
          'cannot be used this character: '
          '${String.fromCharCode(rune)}',
          ErrorType.operand,
        );
        state = State.error;
        break;
      case State.label:
        // |LABEL6789
        // |````````^ over length(8)
        if (pointer == 8) {
          error = Error(
            'label must be within 8 digits',
            ErrorType.operand,
          );
          state = State.error;
          break;
        }
        // |LABEL
        // |`^ label!
        // +
        // |LABEL01
        // |``````^ label!
        if ((rune >= startLabel && rune <= endLabel) ||
            (rune >= startNum && rune <= endNum)) {
          pointer += 1;
          temporary.add(rune);
          state = State.label;
          break;
        }
        // |LABEL,GR1
        // |`````^ delimiter!
        if (rune == comma) {
          label = String.fromCharCodes(temporary);
          temporary.clear();
          pointer = 0;
          state = State.indexRegister;
          break;
        }
        // |LAB#L,GR1
        // |```^ error!
        error = Error(
          'label cannot be used this character: '
          '${String.fromCharCode(rune)}',
          ErrorType.operand,
        );
        state = State.error;
        break;
      case State.indexRegister:
        // |LABEL,GR1
        // |``````^ register?
        // +
        // |LABEL,GR1
        // |```````^ register?
        if (pointer < 2 && rune == register[pointer]) {
          pointer += 1;
          break;
        }
        // |LABEL,GR1
        // |````````^
        if (pointer == 2 && rune >= startNumX && rune <= endNumR) {
          pointer = 3;
          low = int.parse(String.fromCharCode(rune));
          break;
        }
        // |LABEL,X
        // |``````^ error!
        // +
        // |LABEL,GR0
        // |````````^ error!
        // +
        // |LABEL,GR12
        // |`````````^ error!
        error = Error(
          'cannot be used this character: '
          '${String.fromCharCode(rune)}\n'
          'index register can be used GR1 ~ GR7',
          ErrorType.operand,
        );
        state = State.error;
        break;
      case State.hexAddress:
        // |#ABCD
        // |`^ hex address!
        // +
        // |#FF14
        // |````^ hex address!
        if (pointer < 4 &&
            ((rune >= startNum && rune <= endNum) ||
                (rune >= startHex && rune <= endHex))) {
          pointer += 1;
          temporary.add(rune);
          break;
        }
        // |#ABCDE,GR1
        // |``````^ delimiter!
        if (pointer == 4 && rune == comma) {
          address = int.parse(String.fromCharCodes(temporary), radix: 16);
          temporary.clear();
          pointer = 0;
          state = State.indexRegister;
          break;
        }
        // |#ABCDE
        // |`````^ error!
        // +
        // |#A,GR1
        // |``^ error!
        // +
        // |#ABOD
        // |```^ error!
        error = Error(
          'cannot be used this character: '
          '${String.fromCharCode(rune)}\n'
          'and hex address must be 4 digits',
          ErrorType.operand,
        );
        state = State.error;
        break;
      case State.address:
        // |1234
        // |```^ address!
        if (rune >= startNum && rune <= endNum) {
          temporary.add(rune);
          break;
        }
        // |1234,GR1
        // |````^ delimiter!
        if (rune == comma) {
          address = int.parse(String.fromCharCodes(temporary));
          temporary.clear();
          pointer = 0;
          state = State.indexRegister;
          break;
        }
        // |1O0
        // |`^ error!
        error = Error(
          'address cannot be used this character: '
          '${String.fromCharCode(rune)}',
          ErrorType.operand,
        );
        state = State.error;
        break;
      case State.error:
      default:
        return ExResult([], state, error: error);
    }
  }

  // |LABEL[EOF]
  // |`````^ label!
  if (state == State.label) {
    final label = String.fromCharCodes(temporary);
    return ExResult([
      Node(high),
      Node(0, Type.label),
    ], State.label, label: label);
  }

  // |#FF16[EOF]
  // |`````^ hex address!
  if (pointer == 4 && state == State.hexAddress) {
    return ExResult([
      Node(high),
      Node(int.parse(String.fromCharCodes(temporary), radix: 16)),
    ], State.hexAddress);
  }

  // |1234[EOF]
  // |````^ address!
  if (state == State.address) {
    return ExResult([
      Node(high),
      Node(int.parse(String.fromCharCodes(temporary))),
    ], State.address);
  }

  // |#FF14,GR1[EOF]
  // |`````````^ index register!
  // +
  // |12345,GR1[EOF]
  // |`````````^ index register!
  if (pointer == 3 && state == State.indexRegister && address != null) {
    return ExResult([
      Node(high | low),
      Node(address),
    ], State.indexRegister);
  }

  // |LABEL,GR1[EOF]
  // |`````````^ index register!
  if (pointer == 3 && state == State.indexRegister && label != null) {
    return ExResult([
      Node(high | low),
      Node(0, Type.label),
    ], State.indexRegister, label: label);
  }

  return ExResult(
    [],
    state,
    error: Error(
      'syntax error',
      ErrorType.operand,
    ),
  );
}
