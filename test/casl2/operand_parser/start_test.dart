import 'dart:math';

import 'package:tiamat/src/casl2/operand_parser/start.dart';
import 'package:tiamat/src/casl2/core/node.dart';
import 'package:tiamat/src/casl2/core/symbol.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('start', () {
    test('without operand', () {
      final tree = Tree();
      final symbol = Symbol.fromString(
        comment: 'fmm',
        label: 'MAIN',
        opecode: 'START',
        operand: '',
      );

      start(symbol, tree);
      expect(symbol.nodes.length, equals(0));
      expect(tree.nodes.length, equals(0));
      expect(tree.labels.length, equals(0));
      expect(tree.startLabel, equals('MAIN'));
    });

    group('with operand', () {
      test('label', () {
        final tree = Tree();
        final symbol = Symbol.fromString(
          comment: 'label test',
          label: 'MAIN2',
          opecode: 'START',
          operand: 'LABEL',
        );

        start(symbol, tree);
        expect(symbol.nodes.length, equals(2));
        expect(tree.startLabel, equals('MAIN2'));
        // labels
        expect(tree.labels.length, equals(1));
        expect(tree.labels['LABEL'], isNotNull);
        expect(tree.labels['LABEL']?.references?.length, equals(1));
        // nodes
        expect(tree.nodes.length, equals(2));
        expect(tree.nodes[0].code, equals(0x6400));
        expect(tree.nodes[0].type, equals(Type.code));
        expect(tree.nodes[1].type, equals(Type.label));
        expect(
            tree.nodes.first, equals(tree.labels['LABEL']?.references?.first));
      });

      test('address', () {
        final tree = Tree();
        final symbol = Symbol.fromString(
          comment: 'label test',
          label: 'MAIN3',
          opecode: 'START',
          operand: '1234',
        );

        start(symbol, tree);
        expect(symbol.nodes.length, equals(2));
        expect(tree.startLabel, equals('MAIN3'));
        expect(tree.labels.length, equals(0));
        // nodes
        expect(tree.nodes.length, equals(2));
        expect(tree.nodes[0].code, equals(0x6400));
        expect(tree.nodes[0].type, equals(Type.code));
        expect(tree.nodes[1].code, equals(1234));
        expect(tree.nodes[1].type, equals(Type.code));
      });

      test('hex address', () {
        final tree = Tree();
        final symbol = Symbol.fromString(
          comment: 'label test',
          label: 'MAIN3',
          opecode: 'START',
          operand: '#1234',
        );

        start(symbol, tree);
        expect(symbol.nodes.length, equals(2));
        expect(tree.startLabel, equals('MAIN3'));
        expect(tree.labels.length, equals(0));
        // nodes
        expect(tree.nodes.length, equals(2));
        expect(tree.nodes[0].code, equals(0x6400));
        expect(tree.nodes[0].type, equals(Type.code));
        expect(tree.nodes[1].code, equals(0x1234));
        expect(tree.nodes[1].type, equals(Type.code));
      });
    });
  });
}
