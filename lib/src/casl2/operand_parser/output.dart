import '../core/error.dart';
import '../core/symbol.dart';
import '../core/node_tree.dart';
import 'automata/pattern4.dart';
import 'util.dart';
import 'push.dart';
import 'lad.dart';
import 'svc.dart';
import 'pop.dart';

/// A macro of CASL2, named OUT.
Error? output(final Symbol s, final NodeTree t) {
  final result = automata(s.operand);

  if (result.hasError) {
    return result.error;
  }

  // |BUF,255[EOF]
  // |```````^ length!
  // +
  // |BUF,#00FF[EOF]
  // |`````````^ hex length!
  // +
  // |128,255[EOF]
  // |```````^ length!
  // +
  // |#0100,#00FF[EOF]
  // |```````````^ hex length!
  {
    final symbols = <Symbol>[
      Symbol.fromString(opecode: 'PUSH', operand: '0,GR1'),
      Symbol.fromString(opecode: 'PUSH', operand: '0,GR2'),
      if (result.label != null)
        Symbol.fromString(opecode: 'LAD', operand: 'GR1,${result.label}'),
      if (result.address != null)
        Symbol.fromString(opecode: 'LAD', operand: 'GR1,${result.address}'),
      Symbol.fromString(opecode: 'LAD', operand: 'GR2,${result.length}'),
      Symbol.fromString(opecode: 'SVC', operand: '2'),
      Symbol.fromString(opecode: 'POP', operand: 'GR2'),
      Symbol.fromString(opecode: 'POP', operand: 'GR1'),
    ];
    for (final symbol in symbols) {
      switch (String.fromCharCodes(symbol.opecode)) {
        case 'PUSH':
          // TODO
          push(symbol, t);
          break;
        case 'LAD':
          // TODO
          lad(symbol, t);
          break;
        case 'SVC':
          // TODO
          svc(symbol, t);
          break;
        case 'POP':
          // TODO
          pop(symbol, t);
          break;
      }
      s.nodes.addAll(symbol.nodes);
    }
  }
  if (s.label.isNotEmpty) {
    setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
  }

  return null;
}
