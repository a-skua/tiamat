import '../node/node.dart';
import 'util.dart';

enum State {
  none,
  error,

  /// |r,adr,x
  /// | ^ to address|register
  /// +
  /// |r1,r2
  /// |  ^ to address|register
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

/// An instruction of CASL2, named LD.
void ld(final Root r, final Tree t) {
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
  var pointer = 0;
  var operand = 0x1000;
  int? address = null;
  String? label = null;

  var state = State.none;
  for (final rune in r.operand.runes) {
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
          operand |= int.parse(String.fromCharCode(temporaryRegister)) << 4;
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
        break;
    }
  }
  // |GR0,123[EOF]
  // |```````^ address!
  if (state == State.address) {
    r.nodes.addAll([
      Node(operand),
      Node(int.parse(String.fromCharCodes(temporary))),
    ]);
    t.nodes.addAll(r.nodes);
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }
  // |GR0,#FFFF[EOF]
  // |`````````^ hex address!
  if (pointer == 4 && state == State.hexAddress) {
    r.nodes.addAll([
      Node(operand),
      Node(int.parse(String.fromCharCodes(temporary), radix: 16)),
    ]);
    t.nodes.addAll(r.nodes);
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }
  // |GR1,LABEL[EOF]
  // |`````````^ label!
  if (state == State.label) {
    r.nodes.addAll([
      Node(operand),
      Node(0, Type.label),
    ]);
    t.nodes.addAll(r.nodes);
    addReferenceLabel(
      String.fromCharCodes(temporary),
      r.nodes.last,
      t.labels,
    );
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }
  // |GR0,GR1[EOF]
  // |```````^ register2!
  if (pointer == 3 && state == State.register2) {
    operand |= 0x0400 | int.parse(String.fromCharCode(temporaryRegister));
    r.nodes.add(Node(operand));
    t.nodes.addAll(r.nodes);
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }
  // |GR0,0,GR1[EOF]
  // |`````````^ index with address!
  if (pointer == 3 && state == State.indexRegister && address != null) {
    operand |= int.parse(String.fromCharCode(temporaryRegister));
    r.nodes.addAll([
      Node(operand),
      Node(address),
    ]);
    t.nodes.addAll(r.nodes);
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }
  // |GR0,LABEL,GR1[EOF]
  // |`````````````^ index with label!
  if (pointer == 3 && state == State.indexRegister && label != null) {
    operand |= int.parse(String.fromCharCode(temporaryRegister));
    r.nodes.addAll([
      Node(operand),
      Node(0, Type.label),
    ]);
    t.nodes.addAll(r.nodes);
    addReferenceLabel(
      label,
      r.nodes.last,
      t.labels,
    );
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }

  assert(false);
}
