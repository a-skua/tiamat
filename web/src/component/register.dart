import 'dart:html';

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
    this.bits = 16,
    this.hasSigned = true,
  });

  final _volumes = [];
  final values = Element.div()..classes.add('register-values');

  Element render() {
    for (var i = 0; i < bits; i++) {
      _volumes.add(CheckboxInputElement()..id = '$name.$i');
    }
    final element = Element.div()
      ..classes.add('register')
      ..nodes = [
        Element.div()
          ..classes.add('register-name')
          ..nodes.add(Text(name)),
        Element.div()
          ..classes.add('register-bits')
          ..nodes = [
            for (final checkbox in _volumes.reversed)
              Element.div()
                ..classes.add('register-bit')
                ..nodes = [
                  checkbox,
                  Element.div()
                    ..onClick.listen((_) {
                      final checked = !checkbox.checked;
                      checkbox.checked = checked;

                      {
                        final p = checkbox.id.replaceFirst('$name.', '');
                        final maskBit = 1 << int.parse(p);
                        final v = getR();
                        if (checked) {
                          setR(v | maskBit);
                        } else {
                          setR(v & (maskBit ^ -1));
                        }
                      }
                      update();
                    }),
                ]
          ],
        values,
      ];
    update();

    return element;
  }

  void update() {
    final v = getR();

    values.nodes = [
      Element.div()
        ..classes.add('register-value')
        ..nodes.add(Text(v.toString())),
      Element.div()
        ..classes.add('register-value-signed')
        ..nodes = [
          if (hasSigned) Text(v.toSigned(bits).toString()),
        ],
    ];
    for (var i = 0; i < bits; i++) {
      final maskBit = 1 << i;
      _volumes[i].checked = (v & maskBit) > 0;
    }
  }
}
