import 'dart:html';

import 'package:tiamat/tiamat.dart';

Element app() {
  final cc = Casl2();
  final r = Resource();
  final c = Comet2();

  final registers = Element.ul();
  // GR
  for (var i = 0; i < 8; i++) {
    final li = Element.li();
    for (var b = 0; b < wordSize; b++) {
      final gr = CheckboxInputElement()
        ..id = 'gr$i.$b'
        ..onInput.listen((e) {
          final target = e.target;
          if (target != null && target is CheckboxInputElement) {
            final p = target.id.replaceFirst('gr', '').split('.');
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

  final textarea = TextAreaElement()..nodes.add(Text(asm));
  final output = TextAreaElement()..disabled = true;
  c.sv
    ..write = (s) {
      output.nodes.add(Text(s + '\n'));
    }
    ..read = () {
      final s = [
        'hello, world',
        'foo bar baz',
        'exit',
      ];
      var x = 0;
      return () => s[x++ % s.length];
    }();
  final execute = ButtonElement()
    ..nodes.add(Text('execute'))
    ..onClick.listen((_) {
      r.PR = 0;
      r.SP = -1; // TODO bug
      final code = cc.compile(textarea.value ?? '');
      for (var i = 0; i < code.length; i++) {
        r.memory.setWord(r.PR + i, code[i]);
      }
      c.exec(r);
    });
  return Element.div()
    ..nodes = [
      registers,
      textarea,
      output,
      execute,
    ];
}

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
