import 'dart:math';

import 'package:tiamat/src/casl2/operand_parser/ds.dart';
import 'package:tiamat/src/casl2/core/node.dart';
import 'package:tiamat/src/casl2/core/node_tree.dart';
import 'package:tiamat/src/casl2/core/symbol.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('ds', () {
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

    group('hex', () {
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
            operand: '#$size',
          );

          final baseLabelsLength = tree.labels.length;
          final baseNodesLength = tree.nodes.length;

          final expected = int.parse('$size', radix: 16);
          ds(symbol, tree);
          expect(symbol.nodes.length, equals(expected));
          expect(tree.nodes.length, equals(baseNodesLength + expected));
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
