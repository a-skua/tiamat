import 'dart:math';

import 'package:tiamat/src/casl2/operand_parser/ds.dart';
import 'package:tiamat/src/casl2/core/node.dart';
import 'package:tiamat/src/casl2/core/node_tree.dart';
import 'package:tiamat/src/casl2/core/symbol.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('ds', () {
    group('error', () {
      const testdata = [
        'GR0',
        "'hello, world'",
        '',
        '0',
        '-1',
      ];

      for (var i = 0; i < testdata.length; i++) {
        final data = testdata[i];
        test('$i', () {
          final tree = NodeTree();
          final symbol = Symbol.fromString(
            comment: 'error',
            opecode: 'DS',
            operand: data,
          );

          expect(ds(symbol, tree), isNotNull);
          expect(tree.labels.length, equals(0));
          expect(tree.nodes.length, equals(0));
          expect(symbol.nodes.length, equals(0));
        });
      }
    });

    group('decimal', () {
      for (var i = 0; i < 8; i++) {
        test('$i', () {
          final size = rand.nextInt(100) + 1;
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
            comment: 'comment ${rand.nextInt(100)}',
            label: i % 2 > 0 ? 'L${rand.nextInt(100)}' : '',
            opecode: 'DS',
            operand: '${size}',
          );

          final baseLabelsLength = tree.labels.length;
          final baseNodesLength = tree.nodes.length;

          ds(symbol, tree);
          expect(symbol.nodes.length, equals(size));
          expect(tree.nodes.length, equals(baseNodesLength + size));
          for (final node in symbol.nodes) {
            expect(node.type, equals(Type.code));
          }
          expect(
              tree.labels.length,
              equals(symbol.label.isNotEmpty
                  ? baseLabelsLength + 1
                  : baseLabelsLength));
          if (tree.labels.length > baseLabelsLength) {
            expect(tree.labels[String.fromCharCodes(symbol.label)]?.entity,
                equals(symbol.nodes.first));
          }
        });
      }
    });
  });
}
