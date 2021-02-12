import '../core/symbol.dart';
import '../core/node_tree.dart';
import 'pop.dart';
import 'util.dart';

/// A macro of CASL2, named RPOP.
void rpop(final Symbol s, final NodeTree t) {
  {
    final symbols = <Symbol>[
      Symbol.fromString(opecode: 'POP', operand: 'GR7'),
      Symbol.fromString(opecode: 'POP', operand: 'GR6'),
      Symbol.fromString(opecode: 'POP', operand: 'GR5'),
      Symbol.fromString(opecode: 'POP', operand: 'GR4'),
      Symbol.fromString(opecode: 'POP', operand: 'GR3'),
      Symbol.fromString(opecode: 'POP', operand: 'GR2'),
      Symbol.fromString(opecode: 'POP', operand: 'GR1'),
    ];
    for (final symbol in symbols) {
      pop(symbol, t);
      s.nodes.addAll(symbol.nodes);
    }
  }

  if (s.label.isNotEmpty) {
    setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
  }
}
