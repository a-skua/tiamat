import 'dart:html';

import 'package:tiamat/tiamat.dart';

import './register.dart';

class ResourceState {
  final _registers = <Register>[];

  ResourceState(Resource r) {
    this._registers.addAll([
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
    ]);
  }

  void update() {
    for (final r in this._registers) {
      r.update();
    }
  }

  Element render() {
    return DivElement()
      ..nodes = [
        for (final r in this._registers) r.render(),
      ];
  }
}
