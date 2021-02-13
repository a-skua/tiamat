import '../../core/error.dart';
import '../../core/node.dart';
import 'result.dart';

enum State {
  none,
  error,

  /// |r,adr,x
  /// | ^ to address|label|register
  /// +
  /// |r1,r2
  /// |  ^ to address|label|register
  unstable,

  /// |r,adr,x
  /// |^ register
  /// +
  /// |r1,r2
  /// |^^ register
  register,

  /// |r1,r2
  /// |   ^^ register2
  register2,

  /// |r,adr,x
  /// |      ^ index register
  indexRegister,

  /// |r,adr,x
  /// |  ^^^ address|hexAddress|label
  address,
  hexAddress,
  label,
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

/// A first automata.
///
/// Expect one of the two results.
/// Correct syntax: r,adr,x | r1,r2
/// Used [firstHigh] when operand is `r,adr,x`.
/// Used [secondHigh] when operand is `r1,r2`.
ExResult automata(
  final List<int> runes,
  final int firstHigh, [
  final int secondHigh = 0,
]) {
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
  var temporaryRegister = 0;
  var low = 0;
  var pointer = 0;
  int? address = null;
  String? label = null;

  var state = State.none;
  for (final rune in runes) {
    switch (state) {
      case State.none:
        // |GR1,GR2
        // |^ register!
        if (rune == register[0]) {
          pointer = 1;
          state = State.register;
          break;
        }
        // error!
        state = State.error;
        break;
      case State.register:
        // |GR0,0,GR1
        // |`^ true!
        // +
        // |GR7,GR0
        // |`^ true!
        if (pointer == 1 && rune == register[1]) {
          pointer += 1;
          break;
        }
        // |GR0,0,GR1
        // |``^ register?
        // +
        // |GR7,GR0
        // |``^ register?
        if (pointer == 2 && rune >= startNum && rune <= endNumR) {
          pointer = 3;
          temporaryRegister = rune;
          break;
        }
        // |GR0,0,GR1
        // |```^ delimiter!
        // +
        // |GR7,GR0
        // |```^ delimiter!
        if (pointer == 3 && rune == comma) {
          low |= int.parse(String.fromCharCode(temporaryRegister)) << 4;
          temporary.clear();
          pointer = 0;
          state = State.unstable;
          break;
        }
        // |GR01,GR2
        // |```^ error!
        // +
        // |GR0X,0,GR1
        // |```^ error!
        // +
        // |GX0,GR1
        // |`^ error!
        // +
        // |G#7,0,GR6
        // |`^ error!
        state = State.error;
        break;
      case State.unstable:
        // |GR6,GR5
        // |````^ register2?
        if (rune == register[pointer]) {
          pointer = 1;
          temporary.add(rune);
          state = State.register2;
          break;
        }
        // |GR2,LABEL,GR4
        // |````^ label?
        if (rune >= startLabel && rune <= endLabel) {
          pointer = 1;
          temporary.add(rune);
          state = State.label;
          break;
        }
        // |GR1,1234
        // |````^ address!
        if (rune >= startNum && rune <= endNum) {
          temporary.add(rune);
          state = State.address;
          break;
        }
        // |GR0,#FFFF
        // |````^ hex address!
        if (rune == sharp) {
          // exclude sharp!
          pointer = 0;
          state = State.hexAddress;
          break;
        }
        // |GR0,$foo
        // |````^ error!
        // +
        // |GR0,-100
        // |````^ error!
        state = State.error;
        break;
      case State.address:
        // |GR0,0,GR1
        // |`````^ delimiter!
        // +
        // |GR1,45,GR7
        // |``````^ delimiter!
        if (rune == comma) {
          address = int.parse(String.fromCharCodes(temporary));
          temporary.clear();
          pointer = 0;
          state = State.indexRegister;
          break;
        }
        // |GR0,12345
        // |`````^ address!
        // +
        // |GR1,6789,GR4
        // |```````^ address!
        if (rune >= startNum && rune <= endNum) {
          temporary.add(rune);
          break;
        }
        // |GR0,12E45
        // |``````^ error!
        state = State.error;
        break;
      case State.hexAddress:
        // |GR0,#0010,GR1
        // |`````````^ delimiter!
        if (pointer == 4 && rune == comma) {
          address = int.parse(String.fromCharCodes(temporary), radix: 16);
          temporary.clear();
          pointer = 0;
          state = State.indexRegister;
          break;
        }
        // |GR0,#FFFF
        // |`````^ hex address!
        // +
        // |GR3,#0000,GR4
        // |````````^ hex address!
        if (pointer < 4 &&
            ((rune >= startNum && rune <= endNum) ||
                (rune >= startHex && rune <= endHex))) {
          pointer += 1;
          temporary.add(rune);
          break;
        }
        // |GR0,#1,GR1
        // |``````^ error!
        // +
        // |GR0,#00O0
        // |```````^ error!
        state = State.error;
        break;
      case State.label:
        // |GR0,LABEL,GR1
        // |`````````^ delimiter!
        if (rune == comma) {
          label = String.fromCharCodes(temporary);
          pointer = 0;
          temporary.clear();
          state = State.indexRegister;
          break;
        }
        // |GR0,XR012,GR1
        // |````````^ label!
        // +
        // |GR7,LABEL
        // |`````^ label!
        if ((rune >= startNum && rune <= endNum) ||
            (rune >= startLabel && rune <= endLabel)) {
          temporary.add(rune);
          break;
        }
        // |GR7,LAB#L
        // |```````^ error!
        state = State.error;
        break;
      case State.register2:
        // |GR6,GR7
        // |`````^ register?
        // +
        // |GR4,GR567
        // |`````^ register?
        if (pointer == 1 && rune == register[1]) {
          pointer = 2;
          temporary.add(rune);
          break;
        }
        // |GR6,GR7
        // |``````^ register?
        // +
        // |GR4,GR012
        // |``````^ register?
        if (pointer == 2 && rune >= startNum && rune <= endNumR) {
          pointer = 3;
          temporaryRegister = rune;
          temporary.add(rune);
          break;
        }
        // |GR6,GR777
        // |```````^ label!
        // +
        // |GR4,GR8
        // |``````^ label!
        // +
        // |GR2,GOTO
        // |`````^ label!
        if ((rune >= startLabel && rune <= endLabel) ||
            (rune >= startNum && rune <= endNum)) {
          pointer += 1;
          temporary.add(rune);
          state = State.label;
          break;
        }
        // |GR6,GR7,
        // |```````^ error!
        // +
        // |GR4,GR#
        // |``````^ error!
        // +
        // |GR2,G?
        // |`````^ error!
        state = State.error;
        break;
      case State.indexRegister:
        // |GR6,0,GR7
        // |``````^ register?
        // +
        // |GR4,#FFFF,GR567
        // |```````````^ register?
        if (pointer < 2 && rune == register[pointer]) {
          pointer += 1;
          break;
        }
        // |GR6,0,GR7
        // |````````^ register?
        // +
        // |GR4,0,GR012
        // |````````^ register?
        if (pointer == 2 && rune >= startNumX && rune <= endNumR) {
          pointer = 3;
          temporaryRegister = rune;
          break;
        }
        // |GR6,0,GR777
        // |`````````^ error!
        // +
        // |GR4,0,GR8
        // |````````^ error!
        // +
        // |GR2,0,GOTO
        // |```````^ error!
        // +
        // |GR6,0,GR7,
        // |`````````^ error!
        // +
        // |GR4,0,GR#
        // |````````^ error!
        // +
        // |GR2,0,?
        // |``````^ error!
        state = State.error;
        break;
      case State.error:
      default:
    }
  }

  // |GR0,123[EOF]
  // |```````^ address!
  if (state == State.address) {
    return ExResult(
      [
        Node(firstHigh | low),
        Node(int.parse(String.fromCharCodes(temporary))),
      ],
      State.address,
    );
  }

  // |GR0,#FFFF[EOF]
  // |`````````^ hex address!
  if (pointer == 4 && state == State.hexAddress) {
    return ExResult([
      Node(firstHigh | low),
      Node(int.parse(String.fromCharCodes(temporary), radix: 16)),
    ], State.hexAddress);
  }

  // |GR1,LABEL[EOF]
  // |`````````^ label!
  if (state == State.label) {
    final label = String.fromCharCodes(temporary);
    return ExResult([
      Node(firstHigh | low),
      Node(0, Type.label),
    ], State.label, label: label);
  }

  // |GR0,GR1[EOF]
  // |```````^ register2!
  if (pointer == 3 && state == State.register2) {
    low |= int.parse(String.fromCharCode(temporaryRegister));
    return ExResult([
      Node(secondHigh | low),
    ], State.register2);
  }

  // |GR0,0,GR1[EOF]
  // |`````````^ index with address!
  if (pointer == 3 && state == State.indexRegister && address != null) {
    low |= int.parse(String.fromCharCode(temporaryRegister));
    return ExResult([
      Node(firstHigh | low),
      Node(address),
    ], State.indexRegister);
  }

  // |GR0,LABEL,GR1[EOF]
  // |`````````````^ index with label!
  if (pointer == 3 && state == State.indexRegister && label != null) {
    low |= int.parse(String.fromCharCode(temporaryRegister));
    return ExResult([
      Node(firstHigh | low),
      Node(0, Type.label),
    ], State.indexRegister, label: label);
  }

  return ExResult([], state, error: Error('todo', ErrorType.syntax));
}
