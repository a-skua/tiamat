import 'dart:html';

import 'package:tiamat/tiamat.dart';

import './component/resource_state.dart';
import './component/control_panel.dart';
import './component/content_box.dart';
import './component/editor.dart';

const version = '0.1.1+nullsafety';

Element app() {
  final cc = Casl2();
  final r = Resource();
  final c = Comet2();

  final inputValues = <String>[];

  final state = ResourceState(r);
  final editor = Editor(asm);
  final output = TextAreaElement()..disabled = true;
  final input = TextAreaElement()..nodes.add(Text('hello, world!'));
  final control = ControlPanel(r, c, cc, onPreExecute: () {
    inputValues.clear();
    inputValues.addAll((input.value ?? '').split('\n'));
    r.PR = 0;
    r.SP = -1; // TODO bug
  }, onUpdate: () {
    state.update();
  }, getCode: () {
    return editor.value;
  }, clearAll: () {
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
  }, clearIO: () {
    input.value = '';
    output.value = '';
  });

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
      contentBox('control panel', control.render())..id = 'control-panel',
      contentBox('casl2', editor.render())..id = 'editor',
      contentBox('input', input)..id = 'input',
      contentBox('output', output)..id = 'output',
      ...state.render(),
      contentBox(
        'information',
        Element.div()
          ..nodes.addAll([
            Text('$version/'),
            AnchorElement()
              ..target = '_blank'
              ..href = 'https://github.com/a-skua/tiamat'
              ..nodes.add(Text('repository')),
          ]),
      )..id = 'information',
    ];
}

const asm = 'MAIN\tSTART\n'
    '\tIN\tIBUF,255\n'
    '\tOUT\tOBUF,255\n'
    '\tRET\n'
    'OBUF\tDC\t\'input:\'\n'
    'IBUF\tDS\t255\n'
    'EOF\tDC\t#FFFF\n'
    '\tEND\n';
