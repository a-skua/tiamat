import 'dart:html';

import 'package:tiamat/tiamat.dart';

import './component/register.dart';

Element app() {
  final cc = Casl2();
  final r = Resource();
  final c = Comet2();

  final textarea = TextAreaElement()..nodes.add(Text(asm));
  final output = TextAreaElement()..disabled = true;
  final input = TextAreaElement();
  final inputValues = <String>[];

  c.sv
    ..write = (s) {
      output.nodes.add(Text(s + '\n'));
    }
    ..read = () {
      final s = inputValues;
      var x = 0;
      return () => s[x++ % s.length];
    }();
  final registers = [
    for (var i = 0; i < 8; i++)
      Register(
        'GR$i',
        () => r.getGR(i),
        (v) => r.setGR(i, v),
      ),
    Register(
      'SP',
      () => r.SP,
      (v) => r.SP = v,
    ),
    Register(
      'PR',
      () => r.PR,
      (v) => r.PR = v,
    ),
    Register(
      'OF',
      () => r.OF ? 1 : 0,
      (v) => r.OF = v > 0,
      bits: 1,
      hasSigned: false,
    ),
    Register(
      'SF',
      () => r.SF ? 1 : 0,
      (v) => r.SF = v > 0,
      bits: 1,
      hasSigned: false,
    ),
    Register(
      'ZF',
      () => r.ZF ? 1 : 0,
      (v) => r.ZF = v > 0,
      bits: 1,
      hasSigned: false,
    ),
  ];

  return Element.div()
    ..nodes = [
      textarea,
      output,
      input,
      ButtonElement()
        ..nodes.add(Text('execute'))
        ..onClick.listen((_) {
          inputValues.clear();
          inputValues.addAll((input.value ?? '').split('\n'));
          r.PR = 0;
          r.SP = -1; // TODO bug
          final code = cc.compile(textarea.value ?? '');
          for (var i = 0; i < code.length; i++) {
            r.memory.setWord(r.PR + i, code[i]);
          }
          c.exec(r);
          for (final r in registers) {
            r.update();
          }
        }),
      for (final r in registers) r.render(),
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
