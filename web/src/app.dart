import 'dart:html';

import 'package:tiamat/tiamat.dart';

import './component/resource_state.dart';
import './component/control_panel.dart';
import './component/content_box.dart';
import './component/editor.dart';

Element app() {
  final cc = Casl2();
  final r = Resource();
  final c = Comet2();

  final inputValues = <String>[];

  final state = ResourceState(r);
  final editor = Editor(asm);
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
      return editor.value;
    },
    clearAll: () {
      input.value = '';
      output.value = '';
      editor.value = '';
      r.SP = -1;
      r.FR = 0;
      r.PR = 0;
      for (var i = 0; i < 8; i++) {
        r.setGR(i, 0);
      }
      state.update();
    },
  );

  c.sv
    ..write = (s) {
      output.value = '${output.value ?? ''}$s\n';
    }
    ..read = () {
      final s = inputValues;
      var x = 0;
      return () => s[x++ % s.length];
    }();

  return Element.div()
    ..id = 'wrap'
    ..nodes = [
      contentBox('control panel', control.render())
        ..style.textAlign = 'right'
        ..style.gridColumn = '1 / 3'
        ..style.gridRow = '1',
      contentBox('casl2', editor.render())
        ..style.height = '24em'
        ..style.gridColumn = '1'
        ..style.gridRow = '2 / 4',
      contentBox('input', input)
        ..style.gridColumn = '2'
        ..style.gridRow = '2',
      contentBox('output', output)
        ..style.gridColumn = '2'
        ..style.gridRow = '3',
      contentBox('input', state.render())
        ..style.gridColumn = '1 / 3'
        ..style.gridRow = '4',
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
