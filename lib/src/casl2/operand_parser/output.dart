import '../core/symbol.dart';
import '../core/node.dart';
import 'automata/pattern4.dart';
import 'util.dart';
import 'push.dart';
import 'lad.dart';
import 'svc.dart';
import 'pop.dart';

/// A macro of CASL2, named OUT.
void output(final Symbol s, final Tree t) {
  final result = automata(s.operand);

  // TODO: make error handling.
  assert(result.hasNotError);

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
          push(symbol, t);
          break;
        case 'LAD':
          lad(symbol, t);
          break;
        case 'SVC':
          svc(symbol, t);
          break;
        case 'POP':
          pop(symbol, t);
          break;
      }
      s.nodes.addAll(symbol.nodes);
    }
  }
  if (s.label.isNotEmpty) {
    setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
  }
}
