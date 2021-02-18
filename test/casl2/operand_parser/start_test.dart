import 'dart:math';

import 'package:tiamat/src/casl2/operand_parser/start.dart';
import 'package:tiamat/src/casl2/core/node.dart';
import 'package:tiamat/src/casl2/core/node_tree.dart';
import 'package:tiamat/src/casl2/core/symbol.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('start', () {
    group('error', () {
      const testdata = [
        'gr1,ge2',
        'Gr2,GR2',
        'GR,GR2',
        'GR8,GR5',
        'GRX,GR8',
        'GR7,GR6,GR0',
        'GR7,GR8,GR0',
        'GR7,Label',
        'GR7',
        'GR0,LABEL56789',
        '#FFFF',
        '0',
      ];

      for (var i = 0; i < testdata.length; i++) {
        final data = testdata[i];
        test('$i', () {
          final tree = NodeTree();
          final symbol = Symbol.fromString(
            comment: 'error',
            opecode: 'START',
            operand: data,
          );

          expect(start(symbol, tree), isNotNull);
          expect(tree.labels.length, equals(0));
          expect(tree.nodes.length, equals(0));
          expect(symbol.nodes.length, equals(0));
        });
      }
    });

    test('without operand', () {
      final tree = NodeTree();
      final symbol = Symbol.fromString(
        comment: 'fmm',
        label: 'MAIN',
        opecode: 'START',
        operand: '',
      );

      expect(start(symbol, tree), isNull);
      expect(symbol.nodes.length, equals(0));
      expect(tree.nodes.length, equals(0));
      expect(tree.labels.length, equals(0));
      expect(tree.startLabel, equals('MAIN'));
    });

    group('with operand', () {
      test('label', () {
        final tree = NodeTree();
        final symbol = Symbol.fromString(
          comment: 'label test',
          label: 'MAIN2',
          opecode: 'START',
          operand: 'LABEL',
        );

        expect(start(symbol, tree), isNull);
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
            tree.nodes.last, equals(tree.labels['LABEL']?.references?.first));
      });
    });
  });
}
