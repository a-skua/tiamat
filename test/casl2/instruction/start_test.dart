import 'dart:math';

import 'package:tiamat/src/casl2/instruction/start.dart';
import 'package:tiamat/src/casl2/node/node.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('test', () {
    test('without operand', () {
      final tree = Tree();
      final root = Root(
        comment: 'fmm',
        label: 'MAIN',
        instruction: 'START',
        operand: '',
      );

      start(root, tree);
      expect(root.nodes.length, equals(0));
      expect(tree.nodes.length, equals(0));
      expect(tree.labels.length, equals(0));
      expect(tree.startLabel, equals('MAIN'));
    });

    group('with operand', () {
      test('label', () {
        final tree = Tree();
        final root = Root(
          comment: 'label test',
          label: 'MAIN2',
          instruction: 'START',
          operand: 'LABEL',
        );

        start(root, tree);
        expect(root.nodes.length, equals(2));
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
        final root = Root(
          comment: 'label test',
          label: 'MAIN3',
          instruction: 'START',
          operand: '1234',
        );

        start(root, tree);
        expect(root.nodes.length, equals(2));
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
        final root = Root(
          comment: 'label test',
          label: 'MAIN3',
          instruction: 'START',
          operand: '#1234',
        );

        start(root, tree);
        expect(root.nodes.length, equals(2));
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
