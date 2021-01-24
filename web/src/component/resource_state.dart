import 'dart:html';

import 'package:tiamat/tiamat.dart' show Resource;

import 'register.dart';
import 'content_box.dart';

class ResourceState {
  final _generalRegisters = <Register>[];
  final _flagRegister = <Register>[];
  var _stackPointer = Register('', () => 0, (_) {});
  var _programRegister = Register('', () => 0, (_) {});

  ResourceState(Resource r) {
    this._generalRegisters.addAll([
      for (var i = 0; i < 8; i++)
        Register(
          'GR$i',
          () => r.getGR(i),
          (v) => r.setGR(i, v),
        ),
    ]);

    this._stackPointer = Register(
      'SP',
      () => r.SP,
      (v) => r.SP = v,
    );
    this._programRegister = Register(
      'PR',
      () => r.PR,
      (v) => r.PR = v,
    );
    this._flagRegister.addAll([
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
    for (final r in this._generalRegisters) {
      r.update();
    }
    this._stackPointer.update();
    this._programRegister.update();
    for (final r in this._flagRegister) {
      r.update();
    }
  }

  List<Element> render() {
    return [
      contentBox(
        'general registers',
        Element.div()
          ..nodes = [
            for (final r in this._generalRegisters) r.render(),
          ],
      )..id = 'general-registers',
      contentBox('stack pointer', this._stackPointer.render())
        ..id = 'stack-pointer',
      contentBox('program register', this._programRegister.render())
        ..id = 'program-register',
      contentBox(
        'flag register',
        Element.div()
          ..nodes = [
            for (final r in this._flagRegister) r.render(),
          ],
      )..id = 'flag-register',
    ];
  }
}
