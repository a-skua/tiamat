import 'dart:math';

import 'package:tiamat/src/casl2/operand_parser/nop.dart';
import 'package:tiamat/src/casl2/core/node.dart';
import 'package:tiamat/src/casl2/core/node_tree.dart';
import 'package:tiamat/src/casl2/core/symbol.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('nop', () {
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
            opecode: 'NOP',
            operand: data,
          );

          expect(nop(symbol, tree), isNotNull);
          expect(tree.labels.length, equals(0));
          expect(tree.nodes.length, equals(0));
          expect(symbol.nodes.length, equals(0));
        });
      }
    });

    group('with label', () {
      for (var i = 0; i < 4; i++) {
        test('$i', () {
          final label = 'LABEL$i';

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
            comment: 'nop test with label $i',
            label: label,
            opecode: 'NOP',
            operand: '',
          );

          final baseLabelsLength = tree.labels.length;
          final baseNodesLength = tree.nodes.length;

          expect(nop(symbol, tree), isNull);
          expect(tree.nodes.length, equals(baseNodesLength + 1));
          expect(tree.labels.length, equals(baseLabelsLength + 1));
          expect(symbol.nodes.length, equals(1));

          expect(symbol.nodes.first, equals(tree.nodes.last));
          expect(symbol.nodes.first.type, equals(Type.code));
          expect(symbol.nodes.first.code, equals(0));
          expect(tree.labels[label], isNot(equals(null)));
          expect(tree.labels[label]?.entity, equals(symbol.nodes.first));
        });
      }
    });

    group('without label', () {
      for (var i = 0; i < 4; i++) {
        test('$i', () {
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
            comment: 'nop test with label $i',
            label: '',
            opecode: 'NOP',
            operand: '',
          );

          final baseLabelsLength = tree.labels.length;
          final baseNodesLength = tree.nodes.length;

          expect(nop(symbol, tree), isNull);
          expect(tree.nodes.length, equals(baseNodesLength + 1));
          expect(tree.labels.length, equals(baseLabelsLength));
          expect(symbol.nodes.length, equals(1));

          expect(symbol.nodes.first, equals(tree.nodes.last));
          expect(symbol.nodes.first.type, equals(Type.code));
          expect(symbol.nodes.first.code, equals(0));
        });
      }
    });
  });
}
