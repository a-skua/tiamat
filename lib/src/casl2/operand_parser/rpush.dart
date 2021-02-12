import '../core/symbol.dart';
import '../core/node.dart';
import 'push.dart';
import 'util.dart';

/// A macro of CASL2, named RPUSH.
void rpush(final Symbol s, final Tree t) {
  {
    final symbols = <Symbol>[
      Symbol.fromString(opecode: 'PUSH', operand: '0,GR1'),
      Symbol.fromString(opecode: 'PUSH', operand: '0,GR2'),
      Symbol.fromString(opecode: 'PUSH', operand: '0,GR3'),
      Symbol.fromString(opecode: 'PUSH', operand: '0,GR4'),
      Symbol.fromString(opecode: 'PUSH', operand: '0,GR5'),
      Symbol.fromString(opecode: 'PUSH', operand: '0,GR6'),
      Symbol.fromString(opecode: 'PUSH', operand: '0,GR7'),
    ];
    for (final symbol in symbols) {
      push(symbol, t);
      s.nodes.addAll(symbol.nodes);
    }
  }

  if (s.label.isNotEmpty) {
    setLabel(String.fromCharCodes(s.label), s.nodes.first, t.labels);
  }
}
