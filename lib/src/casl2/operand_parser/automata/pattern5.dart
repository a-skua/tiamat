import '../../../util/charcode.dart';
import '../../core/error.dart';
import '../../core/node.dart';
import 'result.dart';

enum State {
  none,
  error,

  /// |'It''s a small world.'
  /// | ^^.^^^^^^^^^^^^^^^^^ string
  string,

  /// |'It''s a small world.'
  /// |^..^.................^ meta char
  metaChar,

  /// |-1
  /// |^^ address
  address,

  /// |#FF16
  /// |^^^^^ hex address
  hexAddress,

  /// |LABEL
  /// |^^^^^ label
  label,

  /// |GR00
  /// |^^^ register?
  register,
}

class ExResult extends Result {
  final Map<String, Node> labels;
  ExResult(
    List<Node> values,
    State lastState, {
    Error? error = null,
    this.labels = const {},
  }) : super(values, lastState, error: error);
}

/// A fifth automata.
///
/// Syntax: const,const...
ExResult automata(final List<int> runes) {
  final quote = '\''.runes.first;
  final sharp = '#'.runes.first;
  final comma = ','.runes.first;
  final minus = '-'.runes.first;
  final startNum = '0'.runes.first;
  final endNum = '9'.runes.first;
  final endNumR = '7'.runes.first;
  final startHex = 'A'.runes.first;
  final endHex = 'F'.runes.first;
  final startLabel = 'A'.runes.first;
  final endLabel = 'Z'.runes.first;
  final register = 'GR'.runes.toList();

  final labels = <String, Node>{};
  final nodes = <Node>[];
  Error? error = null;
  // state
  var state = State.none;
  final temporary = <int>[];
  for (final rune in runes) {
    switch (state) {
      case State.none:
        // |'hello, world'
        // |^ string!
        // +
        // |'foo','bar'
        // |``````^ string!
        if (rune == quote) {
          // exclude quote!
          temporary.clear();
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
          temporary.clear();
          state = State.hexAddress;
          break;
        }
        // |-1
        // |^
        // +
        // |-1,-4
        // |```^
        if (rune == minus) {
          temporary.clear();
          temporary.add(rune);
          state = State.address;
          break;
        }
        // |1234
        // |^ address(decimal)!
        // +
        // |123,456
        // |````^ address(decimal)!
        if (rune >= startNum && rune <= endNum) {
          temporary.clear();
          temporary.add(rune);
          state = State.address;
          break;
        }
        // |GX0
        // |^ register?
        // +
        // |0,GR1
        // |``^ register?
        if (rune == register[0]) {
          temporary.clear();
          temporary.add(rune);
          state = State.register;
          break;
        }
        // |LABEL
        // |^ label!
        // +
        // |FOO,BAR
        // |```````^ label!
        if (rune >= startLabel && rune <= endLabel) {
          temporary.clear();
          temporary.add(rune);
          state = State.label;
          break;
        }
        // |,!@#
        // |^ error!
        // +
        // |-1,!@#
        // |```^ error!
        error = Error(
          'cannot be used this character: '
          '${String.fromCharCode(rune)}',
          ErrorType.operand,
        );
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
        temporary.add(rune);
        break;
      case State.address:
        // |123,456
        // |```^ delimiter!
        if (rune == comma) {
          // parse to code.
          nodes.add(Node(int.parse(
            String.fromCharCodes(temporary),
          )));
          temporary.clear();
          state = State.none;
          break;
        }
        // |123456
        // |```^ address(decimal)!
        if (rune >= startNum && rune <= endNum) {
          temporary.add(rune);
          break;
        }
        // |12E456
        // |``^ error!
        error = Error(
          'address cannot be used this character: '
          '${String.fromCharCode(rune)}',
          ErrorType.operand,
        );
        state = State.error;
        break;
      case State.hexAddress:
        // |#ABCD,#1234
        // |`````^ delimiter!
        if (temporary.length == 4 && rune == comma) {
          // parse to code.
          nodes.add(Node(int.parse(
            String.fromCharCodes(temporary),
            radix: 16,
          )));
          temporary.clear();
          state = State.none;
          break;
        }
        // |#F,-1
        // |``^ error!
        if (rune == comma) {
          error = Error(
            'hex address must be 4 digits',
            ErrorType.operand,
          );
          state = State.error;
          break;
        }
        // |#ABCD,#1234
        // |```^ address(hex)!
        // +
        // |#ABCD,#1234
        // |``````````^ address(hex)!
        if ((rune >= startNum && rune <= endNum) ||
            (rune >= startHex && rune <= endHex)) {
          temporary.add(rune);
          break;
        }
        // |#00O0
        // |```^ error!
        error = Error(
          'hex address cannot be used this character: '
          '${String.fromCharCode(rune)}',
          ErrorType.operand,
        );
        state = State.error;
        break;
      case State.label:
        // |LABEL1,LABEL2
        // |``````^ delimiter!
        if (temporary.length <= 8 && rune == comma) {
          nodes.add(Node(0, Type.label));
          labels[String.fromCharCodes(temporary)] = nodes.last;
          temporary.clear();
          state = State.none;
          break;
        }
        // |LABEL6789
        // |````````^ over length!
        if (rune == comma) {
          error = Error(
            'label must be within 8 digits',
            ErrorType.operand,
          );
          state = State.error;
          break;
        }
        // |LABEL
        // |```^ label!
        // |LABEL1,LABEL2
        // |````````````^ label!
        if ((rune >= startLabel && rune <= endLabel) ||
            (rune >= startNum && rune <= endNum)) {
          temporary.add(rune);
          break;
        }
        // |LaBeL
        // |`^ error!
        // +
        // |LABEL#
        // |`````^ error!
        error = Error(
          'label cannot be used this character: '
          '${String.fromCharCode(rune)}',
          ErrorType.operand,
        );
        state = State.error;
        break;
      case State.register:
        // |GRX,0
        // |`^ register?
        // +
        // |0,GR7
        // |```^ register?
        if (temporary.length == 1 && rune == register[1]) {
          temporary.add(rune);
          break;
        }
        // |0,GR7
        // |````^ register?
        if (temporary.length == 2 && rune >= startNum && rune <= endNumR) {
          temporary.add(rune);
          break;
        }
        // |GR7,0
        // |```^ register!
        if (temporary.length == 3 && rune == comma) {
          error = Error(
            'register\'s name cannot be used by label',
            ErrorType.operand,
          );
          state = State.error;
          break;
        }
        // |GX,0
        // |`^ label!
        // +
        // |0,GR8
        // |````^ label!
        if ((rune >= startLabel && rune <= endLabel) ||
            (rune >= startNum && rune <= endNum)) {
          temporary.add(rune);
          state = State.label;
          break;
        }
        // |GR$
        // |``^ error!
        // +
        // |GR0#
        // |```^ error!
        error = Error(
          'label cannot be used this character: '
          '${String.fromCharCode(rune)}',
          ErrorType.operand,
        );
        state = State.error;
        break;
      case State.metaChar:
        // |'hello, world!','it''s a small world.'
        // |```````````````^ delimiter!
        if (rune == comma) {
          // parse to code.
          nodes.addAll(List.generate(
            temporary.length,
            (i) => Node(
              char2code[String.fromCharCode(temporary[i])] ?? 0,
            ),
          ));
          temporary.clear();
          state = State.none;
          break;
        }
        // |'hello, world!','it''s a small world.'
        // |````````````````````^ string!
        if (rune == quote) {
          temporary.add(rune);
          state = State.string;
          break;
        }
        // |'error'\'
        // |```````^ error!
        error = Error(
          'cannot be used this character on alter string: '
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

  // |'hello, world!'[EOF]
  // |```````````````^ string!
  if (state == State.metaChar) {
    nodes.addAll(List.generate(
      temporary.length,
      (i) => Node(temporary[i]),
    ));
    return ExResult(nodes, state, labels: labels);
  }

  // |LABEL[EOF]
  // |`````^ label!
  if (state == State.label) {
    nodes.add(Node(0, Type.label));
    labels[String.fromCharCodes(temporary)] = nodes.last;
    return ExResult(nodes, state, labels: labels);
  }

  // |-1234[EOF]
  // |`````^ address(decimal)!
  if (state == State.address) {
    nodes.add(Node(int.parse(
      String.fromCharCodes(temporary),
    )));
    return ExResult(nodes, state, labels: labels);
  }

  // |#FFFF[EOF]
  // |`````^ address(hex)!
  if (temporary.length == 4 && state == State.hexAddress) {
    nodes.add(Node(int.parse(
      String.fromCharCodes(temporary),
      radix: 16,
    )));
    return ExResult(nodes, state, labels: labels);
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
