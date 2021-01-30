import '../node/node.dart';
import '../../util/charcode.dart';
import 'util.dart';

enum State {
  none,
  string,
  address,
  hexAddress,
  label,
  metaChar,
  error,
}

/// An instruction of CASL2, named DC.
///
/// To define constants.
void dc(final Root r, final Tree t) {
  final quote = '\''.runes.first;
  final sharp = '#'.runes.first;
  final comma = ','.runes.first;
  final minus = '-'.runes.first;
  final startNum = '0'.runes.first;
  final endNum = '9'.runes.first;
  final startHex = 'A'.runes.first;
  final endHex = 'F'.runes.first;
  final startLabel = 'A'.runes.first;
  final endLabel = 'Z'.runes.first;

  // value
  var constant = <int>[];
  // state
  var state = State.none;
  for (final rune in r.operand.runes) {
    switch (state) {
      case State.none:
        // |'hello, world'
        // |^ string!
        // +
        // |'foo','bar'
        // |``````^ string!
        if (rune == quote) {
          // exclude quote!
          state = State.string;
          break;
        }
        // |#ABCD
        // |^ address(hex)!
        // +
        // |#ABCD,#1234
        // |``````^ address(hex)!
        if (rune == sharp) {
          // exclude sharp!
          state = State.hexAddress;
          break;
        }
        // |-1
        // |^
        // +
        // |-1,-4
        // |```^
        if (rune == minus) {
          constant.add(rune);
          state = State.address;
          break;
        }
        // |1234
        // |^ address(decimal)!
        // +
        // |123,456
        // |````^ address(decimal)!
        if (rune >= startNum && rune <= endNum) {
          constant.add(rune);
          state = State.address;
          break;
        }
        // |LABEL
        // |^ label!
        // +
        // |FOO,BAR
        // |```````^ label!
        if (rune >= startLabel && rune <= endLabel) {
          constant.add(rune);
          state = State.label;
          break;
        }
        // |,!@#
        // |^ error!
        // +
        // |-1,!@#
        // |```^ error!
        state = State.error;
        break;
      case State.string:
        // |'hello, world!'
        // |``````````````^ meta char!
        // +
        // |'it''s a small world'
        // |```^ meta char!
        if (rune == quote) {
          // exclude quote!
          state = State.metaChar;
          break;
        }
        // |'hello, world'
        // |````^ string!
        constant.add(rune);
        break;
      case State.address:
        // |123,456
        // |```^ delimiter!
        if (rune == comma) {
          // parse to code.
          r.nodes.add(Node(int.parse(
            String.fromCharCodes(constant),
          )));
          constant.clear();
          state = State.none;
          break;
        }
        // |123456
        // |```^ address(decimal)!
        if (rune >= startNum && rune <= endNum) {
          constant.add(rune);
          break;
        }
        // |12E456
        // |``^ error!
        state = State.error;
        break;
      case State.hexAddress:
        // |#ABCD,#1234
        // |`````^ delimiter!
        if (rune == comma) {
          // parse to code.
          r.nodes.add(Node(int.parse(
            String.fromCharCodes(constant),
            radix: 16,
          )));
          constant.clear();
          state = State.none;
          break;
        }
        // |#ABCD,#1234
        // |```^ address(hex)!
        // +
        // |#ABCD,#1234
        // |``````````^ address(hex)!
        if ((rune >= startNum && rune <= endNum) ||
            (rune >= startHex && rune <= endHex)) {
          constant.add(rune);
          break;
        }
        // |#00O0
        // |```^ error!
        state = State.error;
        break;
      case State.label:
        // |LABEL1,LABEL2
        // |``````^ delimiter!
        if (rune == comma) {
          r.nodes.add(Node(0, Type.label));
          addReferenceLabel(
            String.fromCharCodes(constant),
            r.nodes.last,
            t.labels,
          );
          constant.clear();
          state = State.none;
          break;
        }
        // |LABEL
        // |```^ label!
        // |LABEL1,LABEL2
        // |````````````^ label!
        if ((rune >= startLabel && rune <= endLabel) ||
            (rune >= startNum && rune <= endNum)) {
          constant.add(rune);
          break;
        }
        // |LaBeL
        // |`^ error!
        // +
        // |LABEL#
        // |`````^ error!
        state = State.error;
        break;
      case State.metaChar:
        // |'hello, world!','it''s a small world.'
        // |```````````````^ delimiter!
        if (rune == comma) {
          // parse to code.
          r.nodes.addAll(List.generate(
            constant.length,
            (i) => Node(
              char2code[String.fromCharCode(constant[i])] ?? 0,
            ),
          ));
          constant.clear();
          state = State.none;
          break;
        }
        // |'hello, world!','it''s a small world.'
        // |````````````````````^ string!
        if (rune == quote) {
          constant.add(rune);
          state = State.string;
          break;
        }
        // |'error'\'
        // |```````^ error!
        state = State.error;
        break;
      case State.error:
      default:
        break;
    }
  }

  // |'hello, world!'[EOF]
  // |```````````````^ string!
  if (state == State.metaChar) {
    r.nodes.addAll(List.generate(
      constant.length,
      (i) => Node(constant[i]),
    ));
    t.nodes.addAll(r.nodes);
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }

  // |LABEL[EOF]
  // |`````^ label!
  if (state == State.label) {
    r.nodes.add(Node(0, Type.label));
    addReferenceLabel(
      String.fromCharCodes(constant),
      r.nodes.last,
      t.labels,
    );
    t.nodes.addAll(r.nodes);
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }

  // |-1234[EOF]
  // |`````^ address(decimal)!
  if (state == State.address) {
    r.nodes.add(Node(int.parse(
      String.fromCharCodes(constant),
    )));
    t.nodes.addAll(r.nodes);
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }

  // |#FFFF[EOF]
  // |`````^ address(hex)!
  if (state == State.hexAddress) {
    r.nodes.add(Node(int.parse(
      String.fromCharCodes(constant),
      radix: 16,
    )));
    t.nodes.addAll(r.nodes);
    if (r.label.isNotEmpty) {
      setLabel(r.label, r.nodes.first, t.labels);
    }
    return;
  }

  assert(state != State.string);
  assert(state != State.none);
  assert(state != State.error);
}
