import '../node/node.dart';
import '../../util/charcode.dart';
import 'util.dart';

enum _State {
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
  var state = _State.none;
  for (final rune in r.operand.runes) {
    switch (state) {
      case _State.none:
        // |'hello, world'
        // |^ string!
        // +
        // |'foo','bar'
        // |``````^ string!
        if (rune == quote) {
          // exclude quote!
          state = _State.string;
          break;
        }
        // |#ABCD
        // |^ address(hex)!
        // +
        // |#ABCD,#1234
        // |``````^ address(hex)!
        if (rune == sharp) {
          // exclude sharp!
          state = _State.hexAddress;
          break;
        }
        // |-1
        // |^
        // +
        // |-1,-4
        // |```^
        if (rune == minus) {
          constant.add(rune);
          state = _State.address;
          break;
        }
        // |1234
        // |^ address(decimal)!
        // +
        // |123,456
        // |````^ address(decimal)!
        if (rune >= startNum && rune <= endNum) {
          constant.add(rune);
          state = _State.address;
          break;
        }
        // |LABEL
        // |^ label!
        // +
        // |FOO,BAR
        // |```````^ label!
        if (rune >= startLabel && rune <= endLabel) {
          constant.add(rune);
          state = _State.label;
          break;
        }
        // |,!@#
        // |^ error!
        // +
        // |-1,!@#
        // |```^ error!
        state = _State.error;
        break;
      case _State.string:
        // |'hello, world!'
        // |``````````````^ meta char!
        // +
        // |'it''s a small world'
        // |```^ meta char!
        if (rune == quote) {
          // exclude quote!
          state = _State.metaChar;
          break;
        }
        // |'hello, world'
        // |````^ string!
        constant.add(rune);
        break;
      case _State.address:
        // |123,456
        // |```^ delimiter!
        if (rune == comma) {
          // parse to code.
          r.nodes.add(Node(int.parse(
            String.fromCharCodes(constant),
          )));
          constant.clear();
          state = _State.none;
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
        state = _State.error;
        break;
      case _State.hexAddress:
        // |#ABCD,#1234
        // |`````^ delimiter!
        if (rune == comma) {
          // parse to code.
          r.nodes.add(Node(int.parse(
            String.fromCharCodes(constant),
            radix: 16,
          )));
          constant.clear();
          state = _State.none;
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
        state = _State.error;
        break;
      case _State.label:
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
          state = _State.none;
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
        state = _State.error;
        break;
      case _State.metaChar:
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
          state = _State.none;
          break;
        }
        // |'hello, world!','it''s a small world.'
        // |````````````````````^ string!
        if (rune == quote) {
          constant.add(rune);
          state = _State.string;
          break;
        }
        // |'error'\'
        // |```````^ error!
        state = _State.error;
        break;
      case _State.error:
      default:
        break;
    }
  }

  // |'hello, world!'[EOF]
  // |```````````````^ string!
  if (state == _State.metaChar) {
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
  if (state == _State.label) {
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
  if (state == _State.address) {
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
  if (state == _State.hexAddress) {
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

  assert(state != _State.string);
  assert(state != _State.none);
  assert(state != _State.error);
}
