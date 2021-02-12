import 'dart:math';

import 'package:tiamat/src/casl2/core/node.dart';
import 'package:tiamat/src/casl2/core/symbol.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('symbol', () {
    for (var i = 0; i < 8; i++) {
      test('$i', () {
        final comment = 'c${rand.nextInt(0x100)}'.runes.toList();
        final label = 'l${rand.nextInt(0x100)}'.runes.toList();
        final opecode = 'i${rand.nextInt(0x100)}'.runes.toList();
        final operand = 'o${rand.nextInt(0x100)}'.runes.toList();

        final symbol = Symbol(
          comment: comment,
          label: label,
          opecode: opecode,
          operand: operand,
        );

        expect(symbol.comment, equals(comment));
        expect(symbol.label, equals(label));
        expect(symbol.opecode, equals(opecode));
        expect(symbol.operand, equals(operand));
        expect(symbol.nodes.length, equals(0));

        symbol.nodes.addAll(
          List.filled(8, Node(rand.nextInt(0x10000), Type.code)),
        );
        expect(symbol.nodes.length, equals(8));
      });
    }
  });
}
