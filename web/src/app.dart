import 'dart:html';

import 'package:tiamat/tiamat.dart';

import './component/resource_state.dart';
import './component/control_panel.dart';

Element app() {
  final cc = Casl2();
  final r = Resource();
  final c = Comet2();

  final inputValues = <String>[];

  final state = ResourceState(r);
  final editor = TextAreaElement()
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.resize = 'none'
    ..nodes.add(Text(asm));
  final output = TextAreaElement()
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.resize = 'none'
    ..disabled = true;
  final input = TextAreaElement()
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.resize = 'none';
  final control = ControlPanel(
    r,
    c,
    cc,
    onPreExecute: () {
      inputValues.clear();
      inputValues.addAll((input.value ?? '').split('\n'));
      r.PR = 0;
      r.SP = -1; // TODO bug
    },
    onUpdate: () {
      state.update();
    },
    getCode: () {
      return editor.value ?? '';
    },
  );

  c.sv
    ..write = (s) {
      output.nodes.add(Text(s + '\n'));
    }
    ..read = () {
      final s = inputValues;
      var x = 0;
      return () => s[x++ % s.length];
    }();

  return Element.div()
    ..style.display = 'grid'
    ..nodes = [
      Element.div()
        ..style.gridColumn = '1 / 3'
        ..style.gridRow = '1'
        ..nodes = [control.render()],
      Element.div()
        ..style.gridColumn = '1'
        ..style.gridRow = '2 / 4'
        ..nodes = [editor],
      Element.div()
        ..style.gridColumn = '2'
        ..style.gridRow = '2'
        ..nodes = [output],
      Element.div()
        ..style.gridColumn = '2'
        ..style.gridRow = '3'
        ..nodes = [input],
      Element.div()
        ..style.gridColumn = '1 / 3'
        ..style.gridRow = '4'
        ..nodes = [state.render()],
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
