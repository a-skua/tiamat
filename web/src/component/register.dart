import 'dart:html';

import 'package:tiamat/tiamat.dart';

typedef GetR = int Function();
typedef SetR = void Function(int v);

class Register {
  final String name;
  final GetR getR;
  final SetR setR;
  final int bits;
  final bool hasSigned;
  Register(
    this.name,
    this.getR,
    this.setR, {
    this.bits = wordSize,
    this.hasSigned = true,
  });

  final _volumes = [];
  final value = Text('');

  Element render() {
    for (var i = 0; i < this.bits; i++) {
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
          }
          this.update();
        }));
    }
    ;
    final element = Element.div()
      ..nodes = [
        Text(name),
        ...this._volumes.reversed,
        this.value,
      ];
    this.update();
    return element;
  }

  void update() {
    final v = this.getR();

    var text = v.toString();
    if (this.hasSigned) {
      text += ', ${v.toSigned(this.bits)}';
    }
    this.value.text = text;
    for (var i = 0; i < this.bits; i++) {
      final maskBit = 1 << i;
      this._volumes[i].checked = (v & maskBit) > 0;
    }
  }
}
