import 'dart:math';

import 'package:tiamat/src/casl2/operand_parser/rpop.dart';
import 'package:tiamat/src/casl2/core/node.dart';
import 'package:tiamat/src/casl2/core/symbol.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('rpop', () {
    test('with label', () {
      final label = 'LABEL';
      final tree = Tree()
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
        opecode: 'RPOP',
        operand: '',
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;

      rpop(symbol, tree);
      final expected = <Node>[
        // POP     GR7
        Node(0x7170),
        // POP     GR6
        Node(0x7160),
        // POP     GR5
        Node(0x7150),
        // POP     GR4
        Node(0x7140),
        // POP     GR3
        Node(0x7130),
        // POP     GR2
        Node(0x7120),
        // POP     GR1
        Node(0x7110),
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
      final tree = Tree()
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
        opecode: 'RPOP',
        operand: '',
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;

      rpop(symbol, tree);
      final expected = <Node>[
        // POP     GR7
        Node(0x7170),
        // POP     GR6
        Node(0x7160),
        // POP     GR5
        Node(0x7150),
        // POP     GR4
        Node(0x7140),
        // POP     GR3
        Node(0x7130),
        // POP     GR2
        Node(0x7120),
        // POP     GR1
        Node(0x7110),
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
