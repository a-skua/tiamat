import 'dart:html';

import 'package:tiamat/tiamat.dart' show Comet2, Casl2, Resource;

typedef OnPreExecute = void Function();
typedef OnUpdate = void Function();
typedef GetCode = String Function();
typedef ClearAll = void Function();
typedef ClearIO = void Function();

class ControlPanel {
  var _element = Element.div();

  ControlPanel(
    Resource r,
    Comet2 c,
    Casl2 cc, {
    required OnPreExecute onPreExecute,
    required OnUpdate onUpdate,
    required GetCode getCode,
    required ClearAll clearAll,
    required ClearIO clearIO,
  }) {
    this._element = Element.div()
      ..nodes = [
        Element.tag('h1')..nodes.add(Text('COMET2/CASL2 Emulator.')),
        ButtonElement()
          ..classes.add('button')
          ..nodes.add(Text('clear io'.toUpperCase()))
          ..onClick.listen((_) => clearIO()),
        ButtonElement()
          ..classes.add('button')
          ..nodes.add(Text('clear all'.toUpperCase()))
          ..onClick.listen((_) => clearAll()),
        ButtonElement()
          ..classes.add('button')
          ..nodes.add(Text('execute'.toUpperCase()))
          ..onClick.listen((_) {
            onPreExecute();

            final code = cc.compile(getCode());
            c.load(code);
            c.exec();
            onUpdate();
          })
      ];
  }

  Element render() {
    return this._element;
  }
}
