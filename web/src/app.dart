import 'dart:html';

import 'package:tiamat/tiamat.dart';

import './component/resource_state.dart';
import './component/control_panel.dart';
import './component/content_box.dart';
import './component/editor.dart';
import './component/information.dart';

const version = '0.4.0';

Element app() {
  late final state = ResourceState();

  final comet2 = Comet2(
    onUpdate: (r) => state.update(r),
  );
  final r = comet2.resource;

  final inputValues = <String>[];

  final editor = Editor(asm);
  final output = TextAreaElement()..disabled = true;
  final input = TextAreaElement();
  final control = ControlPanel(
    r,
    comet2,
    onPreExecute: () {
      inputValues.clear();
      inputValues.addAll((input.value ?? '').split('\n'));
      r.PR = 0;
      r.SP = -1; // TODO bug
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
      state.update(r);
    },
    clearIO: () {
      input.value = '';
      output.value = '';
    },
  );

  comet2.device
    ..output = (s) {
      output.value = '${output.value ?? ''}$s\n';
    }
    ..input = () {
      final s = inputValues;
      var x = 0;
      return () => s[x++ % s.length];
    }();
  comet2.delay = 10;

  return Element.div()
    ..id = 'wrap'
    ..nodes = [
      control.render()..id = 'control-panel',
      contentBox('casl2', editor.render())..id = 'editor',
      contentBox('input', input)..id = 'input',
      contentBox('output', output)..id = 'output',
      ...state.render(),
      information(version)..id = 'information',
    ];
}

const asm = 'MAIN\tSTART\n'
    '\tOUT\tMSG,255\n'
    '\tRET\n'
    'MSG\tDC\t\'hello, world!\'\n'
    'EOF\tDC\t-1\n'
    '\tEND\n';
