import 'dart:html';

import 'package:tiamat/tiamat.dart' show Resource;

import 'register.dart';
import 'content_box.dart';

class ResourceState {
  final _generalRegisters = <Register>[];
  final _flagRegister = <Register>[];
  var _stackPointer = Register('', () => 0, (_) {});
  var _programRegister = Register('', () => 0, (_) {});

  Resource resource = Resource();

  ResourceState() {
    // TODO continue...
    this._generalRegisters.addAll([
      for (var i = 0; i < 8; i++)
        Register(
          'GR$i',
          () => resource.getGR(i),
          (v) => resource.setGR(i, v),
        ),
    ]);

    this._stackPointer = Register(
      'SP',
      () => resource.SP,
      (v) => resource.SP = v,
    );
    this._programRegister = Register(
      'PR',
      () => resource.PR,
      (v) => resource.PR = v,
    );
    this._flagRegister.addAll([
      Register(
        'OF',
        () => resource.OF ? 1 : 0,
        (v) => resource.OF = v > 0,
        bits: 1,
        hasSigned: false,
      ),
      Register(
        'SF',
        () => resource.SF ? 1 : 0,
        (v) => resource.SF = v > 0,
        bits: 1,
        hasSigned: false,
      ),
      Register(
        'ZF',
        () => resource.ZF ? 1 : 0,
        (v) => resource.ZF = v > 0,
        bits: 1,
        hasSigned: false,
      ),
    ]);
  }

  void update(Resource r) {
    resource = r;
    for (final r in _generalRegisters) {
      r.update();
    }
    _stackPointer.update();
    _programRegister.update();
    for (final r in _flagRegister) {
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
