import '../core/error.dart';
import '../core/symbol.dart';
import '../core/node_tree.dart';
import 'automata/pattern7.dart';
import 'nop.dart';
import 'jump.dart';
import 'util.dart';

/// An instruction of CASL2, named START.
///
/// Start is JUMP to address when has operand.
/// Other than that do nothing.
/// This label must not empty.
Error? start(final Symbol s, final NodeTree t) {
  if (s.label.isEmpty) {
    return Error(
      'START must be LABEL',
      ErrorType.label,
    );
  }

  t.startLabel = String.fromCharCodes(s.label);

  final result = automata(s.operand);
  if (result.hasError) {
    return result.error;
  }

  if (result.lastState == State.label) {
    final symbol = Symbol.fromString(
      opecode: 'JUMP',
      operand: String.fromCharCodes(s.operand),
    );
    final error = jump(symbol, t);
    if (error != null) {
      return error;
    }
    s.nodes.addAll(symbol.nodes);
    return null;
  }

  return null;
}
