import 'dart:math';

import 'package:tiamat/src/instruction.dart';
import 'package:tiamat/src/resource.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  test('no operation', () {
    final r = Resource();
    final ins = Instruction();

    expect(r.PR, equals(0));
    ins.noOperation(r);
    expect(r.PR, equals(1));

    for (var i = 0; i < 8; i++) {
      r.PR = 0;
      final count = rand.nextInt(1 << 16);
      for (var j = 0; j < count; j++) {
        ins.noOperation(r);
      }
      expect(r.PR, equals(count));
    }

    r.PR = (1 << 16) - 1;
    ins.noOperation(r);
    expect(r.PR, equals(0));
  });
}
