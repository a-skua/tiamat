import 'dart:math';

import 'package:tiamat/src/casl2/operand_parser/push.dart';
import 'package:tiamat/src/casl2/core/node.dart';
import 'package:tiamat/src/casl2/core/node_tree.dart';
import 'package:tiamat/src/casl2/core/symbol.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('push', () {
    group('error', () {
      const testdata = [
        'GR0',
        "'hello, world'",
        '',
        '-1',
        'LABEL56789,GR1',
        '0,GR0',
        '#FFF,GR1',
      ];

      for (var i = 0; i < testdata.length; i++) {
        final data = testdata[i];
        test('$i', () {
          final tree = NodeTree();
          final symbol = Symbol.fromString(
            comment: 'error',
            opecode: 'PUSH',
            operand: data,
          );

          expect(push(symbol, tree), isNotNull);
          expect(tree.labels.length, equals(0));
          expect(tree.nodes.length, equals(0));
          expect(symbol.nodes.length, equals(0));
        });
      }
    });

    group('adr,x', () {
      group('address only', () {
        for (var i = 0; i < 16; i++) {
          test('$i', () {
            final label = i % 2 > 0 ? 'LABEL' : '';
            final address = rand.nextInt(0x10000);

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
              comment: 'adr,x',
              label: label,
              opecode: 'PUSH',
              operand: '$address',
            );

            final baseLabelsLength = tree.labels.length;
            final baseNodesLength = tree.nodes.length;

            expect(push(symbol, tree), isNull);
            expect(symbol.nodes.length, equals(2));
            expect(tree.nodes.length, equals(baseNodesLength + 2));
            if (label.isEmpty) {
              expect(tree.labels.length, equals(baseLabelsLength));
              expect(tree.labels[label], equals(null));
            } else {
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], isNot(equals(null)));
              expect(tree.labels[label]?.entity, equals(symbol.nodes.first));
            }
            expect(symbol.nodes[0].code, equals(0x7000));
            expect(symbol.nodes[0].type, equals(Type.code));
            expect(symbol.nodes[1].code, equals(address));
            expect(symbol.nodes[1].type, equals(Type.code));
          });
        }
      });

      group('address with index', () {
        for (var i = 0; i < 16; i++) {
          test('$i', () {
            final label = i % 2 > 0 ? 'LABEL' : '';
            final address = rand.nextInt(0x10000);
            final index = rand.nextInt(7) + 1;

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
              comment: 'adr,x',
              label: label,
              opecode: 'PUSH',
              operand: '$address,GR$index',
            );

            final baseLabelsLength = tree.labels.length;
            final baseNodesLength = tree.nodes.length;

            expect(push(symbol, tree), isNull);
            expect(symbol.nodes.length, equals(2));
            expect(tree.nodes.length, equals(baseNodesLength + 2));
            if (label.isEmpty) {
              expect(tree.labels.length, equals(baseLabelsLength));
              expect(tree.labels[label], equals(null));
            } else {
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], isNot(equals(null)));
              expect(tree.labels[label]?.entity, equals(symbol.nodes.first));
            }
            expect(symbol.nodes[0].code, equals(0x7000 | index));
            expect(symbol.nodes[0].type, equals(Type.code));
            expect(symbol.nodes[1].code, equals(address));
            expect(symbol.nodes[1].type, equals(Type.code));
          });
        }
      });

      group('hex address only', () {
        for (var i = 0; i < 16; i++) {
          test('$i', () {
            final label = i % 2 > 0 ? 'LABEL' : '';
            final address = rand.nextInt(0x10000);

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
              comment: 'adr,x',
              label: label,
              opecode: 'PUSH',
              operand:
                  '#${address.toRadixString(16).toUpperCase().padLeft(4, '0')}',
            );

            final baseLabelsLength = tree.labels.length;
            final baseNodesLength = tree.nodes.length;

            expect(push(symbol, tree), isNull);
            expect(symbol.nodes.length, equals(2));
            expect(tree.nodes.length, equals(baseNodesLength + 2));
            if (label.isEmpty) {
              expect(tree.labels.length, equals(baseLabelsLength));
              expect(tree.labels[label], equals(null));
            } else {
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], isNot(equals(null)));
              expect(tree.labels[label]?.entity, equals(symbol.nodes.first));
            }
            expect(symbol.nodes[0].code, equals(0x7000));
            expect(symbol.nodes[0].type, equals(Type.code));
            expect(symbol.nodes[1].code, equals(address));
            expect(symbol.nodes[1].type, equals(Type.code));
          });
        }
      });

      group('hex address with index', () {
        for (var i = 0; i < 16; i++) {
          test('$i', () {
            final label = i % 2 > 0 ? 'LABEL' : '';
            final address = rand.nextInt(0x10000);
            final index = rand.nextInt(7) + 1;

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
              comment: 'adr,x',
              label: label,
              opecode: 'PUSH',
              operand:
                  '#${address.toRadixString(16).toUpperCase().padLeft(4, '0')},'
                  'GR$index',
            );

            final baseLabelsLength = tree.labels.length;
            final baseNodesLength = tree.nodes.length;

            expect(push(symbol, tree), isNull);
            expect(symbol.nodes.length, equals(2));
            expect(tree.nodes.length, equals(baseNodesLength + 2));
            if (label.isEmpty) {
              expect(tree.labels.length, equals(baseLabelsLength));
              expect(tree.labels[label], equals(null));
            } else {
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], isNot(equals(null)));
              expect(tree.labels[label]?.entity, equals(symbol.nodes.first));
            }
            expect(symbol.nodes[0].code, equals(0x7000 | index));
            expect(symbol.nodes[0].type, equals(Type.code));
            expect(symbol.nodes[1].code, equals(address));
            expect(symbol.nodes[1].type, equals(Type.code));
          });
        }
      });

      group('label only', () {
        for (var i = 0; i < 16; i++) {
          test('$i', () {
            final label = i % 2 > 0 ? 'LABEL' : '';
            final referenceLabel =
                '${i % 2 > 0 ? 'GR' : 'L'}${rand.nextInt(0x10000).toRadixString(16).toUpperCase().padLeft(4, '0')}';

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
              comment: 'adr,x',
              label: label,
              opecode: 'PUSH',
              operand: '$referenceLabel',
            );

            final baseLabelsLength = tree.labels.length;
            final baseNodesLength = tree.nodes.length;

            expect(push(symbol, tree), isNull);
            expect(symbol.nodes.length, equals(2));
            expect(tree.nodes.length, equals(baseNodesLength + 2));
            if (label.isEmpty) {
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], equals(null));
              expect(tree.labels[referenceLabel], isNot(equals(null)));
              expect(
                  tree.labels[referenceLabel]?.references?.length, equals(1));
              expect(tree.labels[referenceLabel]?.references?.first,
                  equals(symbol.nodes.last));
            } else {
              expect(tree.labels.length, equals(baseLabelsLength + 2));
              expect(tree.labels[referenceLabel], isNot(equals(null)));
              expect(
                  tree.labels[referenceLabel]?.references?.length, equals(1));
              expect(tree.labels[referenceLabel]?.references?.first,
                  equals(symbol.nodes.last));
              expect(tree.labels[label], isNot(equals(null)));
              expect(tree.labels[label]?.entity, equals(symbol.nodes.first));
            }
            expect(symbol.nodes[0].code, equals(0x7000));
            expect(symbol.nodes[0].type, equals(Type.code));
            expect(symbol.nodes[1].type, equals(Type.label));
          });
        }
      });

      group('label with index', () {
        for (var i = 0; i < 16; i++) {
          test('$i', () {
            final label = i % 2 > 0 ? 'LABEL' : '';
            final referenceLabel =
                '${i % 2 > 0 ? 'GR' : 'L'}${rand.nextInt(0x10000).toRadixString(16).toUpperCase().padLeft(4, '0')}';
            final index = rand.nextInt(7) + 1;

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
              comment: 'adr,x',
              label: label,
              opecode: 'PUSH',
              operand: '$referenceLabel,'
                  'GR$index',
            );

            final baseLabelsLength = tree.labels.length;
            final baseNodesLength = tree.nodes.length;

            expect(push(symbol, tree), isNull);
            expect(symbol.nodes.length, equals(2));
            expect(tree.nodes.length, equals(baseNodesLength + 2));
            if (label.isEmpty) {
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], equals(null));
              expect(tree.labels[referenceLabel], isNot(equals(null)));
              expect(
                  tree.labels[referenceLabel]?.references?.length, equals(1));
              expect(tree.labels[referenceLabel]?.references?.first,
                  equals(symbol.nodes.last));
            } else {
              expect(tree.labels.length, equals(baseLabelsLength + 2));
              expect(tree.labels[referenceLabel], isNot(equals(null)));
              expect(
                  tree.labels[referenceLabel]?.references?.length, equals(1));
              expect(tree.labels[referenceLabel]?.references?.first,
                  equals(symbol.nodes.last));
              expect(tree.labels[label], isNot(equals(null)));
              expect(tree.labels[label]?.entity, equals(symbol.nodes.first));
            }
            expect(symbol.nodes[0].code, equals(0x7000 | index));
            expect(symbol.nodes[0].type, equals(Type.code));
            expect(symbol.nodes[1].type, equals(Type.label));
          });
        }
      });
    });
  });
}
