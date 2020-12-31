import 'dart:math';

import 'package:tiamat/src/comet2.dart';
import 'package:tiamat/src/resource.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  final rand = Random();
  test('exec', () {
    for (var i = 0; i < 4; i++) {
      final r = Resource();
      final c = Comet2();
      const maskBits = 0xffff;

      final gr = rand.nextInt(8);
      final addl = (0x22 << 8) | (gr << 4);
      final adr = rand.nextInt(1 << 16) | (1 << 15);
      final ret = 0x81 << 8;

      final v1 = rand.nextInt(1 << 16);
      final v2 = rand.nextInt(1 << 16);
      final pr = r.PR;

      r.setGR(gr, v1);
      r.memory.setWord(pr, addl);
      r.memory.setWord(pr + 1, adr);
      r.memory.setWord(pr + 2, ret);
      r.memory.setWord(adr, v2);

      c.exec(r);
      expect(r.getGR(gr), equals((v1 + v2) & maskBits));
      expect(r.PR, equals(0));
      expect(r.SP, equals(0));
    }
  });
}
