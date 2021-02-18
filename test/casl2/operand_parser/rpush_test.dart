import 'dart:math';

import 'package:tiamat/src/casl2/operand_parser/rpush.dart';
import 'package:tiamat/src/casl2/core/node.dart';
import 'package:tiamat/src/casl2/core/node_tree.dart';
import 'package:tiamat/src/casl2/core/symbol.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('rpush', () {
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
      ];

      for (var i = 0; i < testdata.length; i++) {
        final data = testdata[i];
        test('$i', () {
          final tree = NodeTree();
          final symbol = Symbol.fromString(
            comment: 'error',
            opecode: 'RPUSH',
            operand: data,
          );

          expect(rpush(symbol, tree), isNotNull);
          expect(tree.labels.length, equals(0));
          expect(tree.nodes.length, equals(0));
          expect(symbol.nodes.length, equals(0));
        });
      }
    });

    test('with label', () {
      final label = 'LABEL';
      final tree = NodeTree()
        ..nodes.addAll(List.generate(
          rand.nextInt(0x100),
          (i) => Node(i),
        ));
      {
        final length = rand.nextInt(0x100);
        tree.labels.addAll(Map.fromIterables(
          List.generate(length, (i) => '$i${rand.nextInt(0x10000)}'),
          List.generate(length, (_) => Label()),
        ));
      }
      final symbol = Symbol.fromString(
        comment: 'adr,len',
        label: label,
        opecode: 'RPUSH',
        operand: '',
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;

      expect(rpush(symbol, tree), isNull);
      final expected = <Node>[
        // PUSH    0,GR1
        Node(0x7001),
        Node(0),
        // PUSH    0,GR2
        Node(0x7002),
        Node(0),
        // PUSH    0,GR3
        Node(0x7003),
        Node(0),
        // PUSH    0,GR4
        Node(0x7004),
        Node(0),
        // PUSH    0,GR5
        Node(0x7005),
        Node(0),
        // PUSH    0,GR6
        Node(0x7006),
        Node(0),
        // PUSH    0,GR7
        Node(0x7007),
        Node(0),
      ];
      expect(symbol.nodes.length, equals(expected.length));
      expect(tree.nodes.length, equals(baseNodesLength + expected.length));
      for (var i = 0; i < expected.length; i++) {
        expect(symbol.nodes[i].code, equals(expected[i].code));
        expect(symbol.nodes[i].type, equals(expected[i].type));
      }
      expect(tree.labels.length, equals(baseLabelsLength + 1));
      expect(tree.labels[label], isNotNull);
    });

    test('with label', () {
      final tree = NodeTree()
        ..nodes.addAll(List.generate(
          rand.nextInt(0x100),
          (i) => Node(i),
        ));
      {
        final length = rand.nextInt(0x100);
        tree.labels.addAll(Map.fromIterables(
          List.generate(length, (i) => '$i${rand.nextInt(0x10000)}'),
          List.generate(length, (_) => Label()),
        ));
      }
      final symbol = Symbol.fromString(
        comment: 'adr,len',
        label: '',
        opecode: 'RPUSH',
        operand: '',
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;

      expect(rpush(symbol, tree), isNull);
      final expected = <Node>[
        // PUSH    0,GR1
        Node(0x7001),
        Node(0),
        // PUSH    0,GR2
        Node(0x7002),
        Node(0),
        // PUSH    0,GR3
        Node(0x7003),
        Node(0),
        // PUSH    0,GR4
        Node(0x7004),
        Node(0),
        // PUSH    0,GR5
        Node(0x7005),
        Node(0),
        // PUSH    0,GR6
        Node(0x7006),
        Node(0),
        // PUSH    0,GR7
        Node(0x7007),
        Node(0),
      ];
      expect(symbol.nodes.length, equals(expected.length));
      expect(tree.nodes.length, equals(baseNodesLength + expected.length));
      for (var i = 0; i < expected.length; i++) {
        expect(symbol.nodes[i].code, equals(expected[i].code));
        expect(symbol.nodes[i].type, equals(expected[i].type));
      }
      expect(tree.labels.length, equals(baseLabelsLength));
    });
  });
}
