import 'dart:math';

import 'package:tiamat/src/casl2/instruction/adda.dart';
import 'package:tiamat/src/casl2/node/node.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('adda', () {
    group('r1,r2', () {
      for (var i = 0; i < 16; i++) {
        test('$i', () {
          final label = i % 2 > 0 ? 'LABEL' : '';
          final register1 = rand.nextInt(8);
          final register2 = rand.nextInt(8);

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
          final root = Root(
            comment: 'r1,r2',
            label: label,
            instruction: 'ADDA',
            operand: 'GR$register1,GR$register2',
          );

          final baseLabelsLength = tree.labels.length;
          final baseNodesLength = tree.nodes.length;

          adda(root, tree);
          expect(root.nodes.length, equals(1));
          expect(tree.nodes.length, equals(baseNodesLength + 1));
          if (label.isEmpty) {
            expect(tree.labels.length, equals(baseLabelsLength));
            expect(tree.labels[label], equals(null));
          } else {
            expect(tree.labels.length, equals(baseLabelsLength + 1));
            expect(tree.labels[label], isNot(equals(null)));
            expect(tree.labels[label]?.entity, equals(root.nodes.first));
          }
          expect(root.nodes.first.code,
              equals(0x2400 | register1 << 4 | register2));
          expect(root.nodes.first.type, equals(Type.code));
        });
      }
    });

    group('r,adx,x', () {
      group('address only', () {
        for (var i = 0; i < 16; i++) {
          test('$i', () {
            final label = i % 2 > 0 ? 'LABEL' : '';
            final register = rand.nextInt(8);
            final address = rand.nextInt(0x10000);

            final tree = Tree()
              ..nodes.addAll(List.generate(
                rand.nextInt(0x100),
                (i) => Node(i),
              ));
            {
              final length = rand.nextInt(0x100);
              tree.labels.addAll(Map.fromIterables(
                List.generate(length, (i) => '$i${rand.nextInt(0x20000)}'),
                List.generate(length, (_) => Label()),
              ));
            }
            final root = Root(
              comment: 'r,adr,x',
              label: label,
              instruction: 'ADDA',
              operand: 'GR$register,$address',
            );

            final baseLabelsLength = tree.labels.length;
            final baseNodesLength = tree.nodes.length;

            adda(root, tree);
            expect(root.nodes.length, equals(2));
            expect(tree.nodes.length, equals(baseNodesLength + 2));
            if (label.isEmpty) {
              expect(tree.labels.length, equals(baseLabelsLength));
              expect(tree.labels[label], equals(null));
            } else {
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], isNot(equals(null)));
              expect(tree.labels[label]?.entity, equals(root.nodes.first));
            }
            expect(root.nodes[0].code, equals(0x2000 | register << 4));
            expect(root.nodes[0].type, equals(Type.code));
            expect(root.nodes[1].code, equals(address));
            expect(root.nodes[1].type, equals(Type.code));
          });
        }
      });

      group('address with index', () {
        for (var i = 0; i < 16; i++) {
          test('$i', () {
            final label = i % 2 > 0 ? 'LABEL' : '';
            final register = rand.nextInt(8);
            final address = rand.nextInt(0x10000);
            final index = rand.nextInt(7) + 1;

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
            final root = Root(
              comment: 'r,adr,x',
              label: label,
              instruction: 'ADDA',
              operand: 'GR$register,$address,GR$index',
            );

            final baseLabelsLength = tree.labels.length;
            final baseNodesLength = tree.nodes.length;

            adda(root, tree);
            expect(root.nodes.length, equals(2));
            expect(tree.nodes.length, equals(baseNodesLength + 2));
            if (label.isEmpty) {
              expect(tree.labels.length, equals(baseLabelsLength));
              expect(tree.labels[label], equals(null));
            } else {
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], isNot(equals(null)));
              expect(tree.labels[label]?.entity, equals(root.nodes.first));
            }
            expect(root.nodes[0].code, equals(0x2000 | register << 4 | index));
            expect(root.nodes[0].type, equals(Type.code));
            expect(root.nodes[1].code, equals(address));
            expect(root.nodes[1].type, equals(Type.code));
          });
        }
      });

      group('hex address only', () {
        for (var i = 0; i < 16; i++) {
          test('$i', () {
            final label = i % 2 > 0 ? 'LABEL' : '';
            final register = rand.nextInt(8);
            final address = rand.nextInt(0x10000);

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
            final root = Root(
              comment: 'r,adr,x',
              label: label,
              instruction: 'ADDA',
              operand:
                  'GR$register,#${address.toRadixString(16).toUpperCase().padLeft(4, '0')}',
            );

            final baseLabelsLength = tree.labels.length;
            final baseNodesLength = tree.nodes.length;

            adda(root, tree);
            expect(root.nodes.length, equals(2));
            expect(tree.nodes.length, equals(baseNodesLength + 2));
            if (label.isEmpty) {
              expect(tree.labels.length, equals(baseLabelsLength));
              expect(tree.labels[label], equals(null));
            } else {
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], isNot(equals(null)));
              expect(tree.labels[label]?.entity, equals(root.nodes.first));
            }
            expect(root.nodes[0].code, equals(0x2000 | register << 4));
            expect(root.nodes[0].type, equals(Type.code));
            expect(root.nodes[1].code, equals(address));
            expect(root.nodes[1].type, equals(Type.code));
          });
        }
      });

      group('hex address with index', () {
        for (var i = 0; i < 16; i++) {
          test('$i', () {
            final label = i % 2 > 0 ? 'LABEL' : '';
            final register = rand.nextInt(8);
            final address = rand.nextInt(0x10000);
            final index = rand.nextInt(7) + 1;

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
            final root = Root(
              comment: 'r,adr,x',
              label: label,
              instruction: 'ADDA',
              operand: 'GR$register,'
                  '#${address.toRadixString(16).toUpperCase().padLeft(4, '0')},'
                  'GR$index',
            );

            final baseLabelsLength = tree.labels.length;
            final baseNodesLength = tree.nodes.length;

            adda(root, tree);
            expect(root.nodes.length, equals(2));
            expect(tree.nodes.length, equals(baseNodesLength + 2));
            if (label.isEmpty) {
              expect(tree.labels.length, equals(baseLabelsLength));
              expect(tree.labels[label], equals(null));
            } else {
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], isNot(equals(null)));
              expect(tree.labels[label]?.entity, equals(root.nodes.first));
            }
            expect(root.nodes[0].code, equals(0x2000 | register << 4 | index));
            expect(root.nodes[0].type, equals(Type.code));
            expect(root.nodes[1].code, equals(address));
            expect(root.nodes[1].type, equals(Type.code));
          });
        }
      });

      group('label only', () {
        for (var i = 0; i < 16; i++) {
          test('$i', () {
            final label = i % 2 > 0 ? 'LABEL' : '';
            final register = rand.nextInt(8);
            final referenceLabel =
                '${i % 2 > 0 ? 'GR' : 'L'}${rand.nextInt(0x10000).toRadixString(16).toUpperCase().padLeft(4, '0')}';

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
            final root = Root(
              comment: 'r,adr,x',
              label: label,
              instruction: 'ADDA',
              operand: 'GR$register,$referenceLabel',
            );

            final baseLabelsLength = tree.labels.length;
            final baseNodesLength = tree.nodes.length;

            adda(root, tree);
            expect(root.nodes.length, equals(2));
            expect(tree.nodes.length, equals(baseNodesLength + 2));
            if (label.isEmpty) {
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], equals(null));
              expect(tree.labels[referenceLabel], isNot(equals(null)));
              expect(
                  tree.labels[referenceLabel]?.references?.length, equals(1));
              expect(tree.labels[referenceLabel]?.references?.first,
                  equals(root.nodes.last));
            } else {
              expect(tree.labels.length, equals(baseLabelsLength + 2));
              expect(tree.labels[referenceLabel], isNot(equals(null)));
              expect(
                  tree.labels[referenceLabel]?.references?.length, equals(1));
              expect(tree.labels[referenceLabel]?.references?.first,
                  equals(root.nodes.last));
              expect(tree.labels[label], isNot(equals(null)));
              expect(tree.labels[label]?.entity, equals(root.nodes.first));
            }
            expect(root.nodes[0].code, equals(0x2000 | register << 4));
            expect(root.nodes[0].type, equals(Type.code));
            expect(root.nodes[1].type, equals(Type.label));
          });
        }
      });

      group('label with index', () {
        for (var i = 0; i < 16; i++) {
          test('$i', () {
            final label = i % 2 > 0 ? 'LABEL' : '';
            final register = rand.nextInt(8);
            final referenceLabel =
                '${i % 2 > 0 ? 'GR' : 'L'}${rand.nextInt(0x10000).toRadixString(16).toUpperCase().padLeft(4, '0')}';
            final index = rand.nextInt(7) + 1;

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
            final root = Root(
              comment: 'r,adr,x',
              label: label,
              instruction: 'ADDA',
              operand: 'GR$register,'
                  '$referenceLabel,'
                  'GR$index',
            );

            final baseLabelsLength = tree.labels.length;
            final baseNodesLength = tree.nodes.length;

            adda(root, tree);
            expect(root.nodes.length, equals(2));
            expect(tree.nodes.length, equals(baseNodesLength + 2));
            if (label.isEmpty) {
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], equals(null));
              expect(tree.labels[referenceLabel], isNot(equals(null)));
              expect(
                  tree.labels[referenceLabel]?.references?.length, equals(1));
              expect(tree.labels[referenceLabel]?.references?.first,
                  equals(root.nodes.last));
            } else {
              expect(tree.labels.length, equals(baseLabelsLength + 2));
              expect(tree.labels[referenceLabel], isNot(equals(null)));
              expect(
                  tree.labels[referenceLabel]?.references?.length, equals(1));
              expect(tree.labels[referenceLabel]?.references?.first,
                  equals(root.nodes.last));
              expect(tree.labels[label], isNot(equals(null)));
              expect(tree.labels[label]?.entity, equals(root.nodes.first));
            }
            expect(root.nodes[0].code, equals(0x2000 | register << 4 | index));
            expect(root.nodes[0].type, equals(Type.code));
            expect(root.nodes[1].type, equals(Type.label));
          });
        }
      });
    });
  });
}
