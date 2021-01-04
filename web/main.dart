import 'dart:html';

import 'package:tiamat/tiamat.dart';

const asm = 'MAIN\tSTART\n'
    'LOOP\tIN\tIBUF,31\n'
    '\tOUT\tOUT,38\n'
    '\tLAD\tGR1,0\n'
    '\tLD\tGR0,IBUF,GR1\n'
    '\tCPL\tGR0,EXIT,GR1\n'
    '\tJNZ\tLOOP\n'
    '\tLAD\tGR1,1,GR1\n'
    '\tLD\tGR0,IBUF,GR1\n'
    '\tCPL\tGR0,EXIT,GR1\n'
    '\tJNZ\tLOOP\n'
    '\tLAD\tGR1,1,GR1\n'
    '\tLD\tGR0,IBUF,GR1\n'
    '\tCPL\tGR0,EXIT,GR1\n'
    '\tJNZ\tLOOP\n'
    '\tLAD\tGR1,1,GR1\n'
    '\tLD\tGR0,IBUF,GR1\n'
    '\tCPL\tGR0,EXIT,GR1\n'
    '\tJNZ\tLOOP\n'
    '\tLAD\tGR1,1,GR1\n'
    '\tLD\tGR0,IBUF,GR1\n'
    '\tCPL\tGR0,EXIT,GR1\n'
    '\tJNZ\tLOOP\n'
    'END\tOUT\tMSG,32\n'
    '\tRET\n'
    'EXIT\tDC\t\'exit\',#FFFF\n'
    'OUT\tDC\t\'input:\'\n'
    'IBUF\tDS\t31\n'
    'EOF\tDC\t#FFFF\n'
    'MSG\tDC\t\'goodbye!\',#FFFF\n'
    '\tEND\n';

void main() {
  final app = querySelector('#app');
  if (app != null) init(app);
}

final r = Resource();

void init(Element app) {
  final registers = Element.ul();
  // GR
  for (var i = 0; i < 8; i++) {
    final li = Element.li();
    for (var b = 0; b < wordSize; b++) {
      final gr = CheckboxInputElement()
        ..name = 'gr$i.$b'
        ..onInput.listen((e) {
          final target = e.target;
          if (target != null && target is CheckboxInputElement) {
            final p = target.name?.replaceFirst('gr', '')?.split('.') ?? [];
            if (p.length != 2) {
              return;
            }
            final gr = int.parse(p[0]);
            final maskBit = 1 << int.parse(p[1]);
            final v = r.getGR(gr);
            if (target.checked ?? false) {
              r.setGR(gr, v | maskBit);
            } else {
              r.setGR(gr, v & (maskBit ^ -1));
            }
            print(r.getGR(gr));
          }
        });
      li.nodes.insert(0, gr);
    }
    li.nodes.insert(0, Element.span()..text = 'GR$i:');
    registers.nodes.add(li);
  }
  app.nodes.add(registers);
  // TODO
}
