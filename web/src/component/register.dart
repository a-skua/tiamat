import 'dart:html';

import 'package:tiamat/tiamat.dart';

typedef GetR = int Function();
typedef SetR = void Function(int v);

class Register {
  final String name;
  final GetR getR;
  final SetR setR;
  Register(this.name, this.getR, this.setR);

  final _volumes = [];

  Element render() {
    for (var i = 0; i < wordSize; i++) {
      this._volumes.add(CheckboxInputElement()
        ..id = '$name.$i'
        ..onInput.listen((e) {
          final target = e.target;
          if (target != null && target is CheckboxInputElement) {
            final p = target.id.replaceFirst('$name.', '');
            final maskBit = 1 << int.parse(p);
            final v = this.getR();
            if (target.checked ?? false) {
              this.setR(v | maskBit);
            } else {
              this.setR(v & (maskBit ^ -1));
            }
            print(this.getR());
          }
        }));
    }
    ;
    return Element.div()
      ..nodes = [
        Text(name),
        ...this._volumes.reversed,
      ];
  }

  void update() {
    final v = this.getR();

    for (var i = 0; i < wordSize; i++) {
      final maskBit = 1 << i;
      this._volumes[i].checked = (v & maskBit) > 0;
    }
  }
}
