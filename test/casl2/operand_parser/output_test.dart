import 'dart:math';

import 'package:tiamat/src/casl2/operand_parser/output.dart';
import 'package:tiamat/src/casl2/core/node.dart';
import 'package:tiamat/src/casl2/core/node_tree.dart';
import 'package:tiamat/src/casl2/core/symbol.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('out', () {
    group('error', () {
      const testdata = [
        'GR0',
        "'hello, world'",
        '',
        '0',
        '-1',
        'GR1,#FFFF',
        'LABEL,#F',
        'LABEL10,F',
        '0LABEL,12',
        'LABEL0,-12',
        'LABEL6789,12',
      ];

      for (var i = 0; i < testdata.length; i++) {
        final data = testdata[i];
        test('$i', () {
          final tree = NodeTree();
          final symbol = Symbol.fromString(
            comment: 'error',
            opecode: 'OUT',
            operand: data,
          );

          expect(output(symbol, tree), isNotNull);
          expect(tree.labels.length, equals(0));
          expect(tree.nodes.length, equals(0));
          expect(symbol.nodes.length, equals(0));
        });
      }
    });

    group('adr,len', () {
      group('without label', () {
        group('label,decimal', () {
          for (var i = 0; i < 8; i++) {
            test('$i', () {
              final label =
                  'BUF${rand.nextInt(0x100).toRadixString(16).toUpperCase().padLeft(2, '0')}';
              final length = rand.nextInt(0x100);

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
                opecode: 'OUT',
                operand: '$label,$length',
              );

              final baseLabelsLength = tree.labels.length;
              final baseNodesLength = tree.nodes.length;

              expect(output(symbol, tree), isNull);
              final expected = <Node>[
                // PUSH    0,GR1
                Node(0x7001),
                Node(0),
                // PUSH    0,GR2
                Node(0x7002),
                Node(0),
                // LAD     GR1,LABEL
                Node(0x1210),
                Node(0, Type.label),
                // LAD     GR2,LEN
                Node(0x1220),
                Node(length),
                // SVC     2
                Node(0xf000),
                Node(2),
                // POP     GR2
                Node(0x7120),
                // POP     GR1
                Node(0x7110),
              ];
              expect(symbol.nodes.length, equals(expected.length));
              expect(
                  tree.nodes.length, equals(baseNodesLength + expected.length));
              for (var i = 0; i < expected.length; i++) {
                expect(symbol.nodes[i].code, equals(expected[i].code));
                expect(symbol.nodes[i].type, equals(expected[i].type));
              }
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], isNotNull);
            });
          }
        });

        group('label,hex', () {
          for (var i = 0; i < 8; i++) {
            test('$i', () {
              final label =
                  'BUF${rand.nextInt(0x100).toRadixString(16).toUpperCase().padLeft(2, '0')}';
              final length = rand.nextInt(0x100);

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
                opecode: 'OUT',
                operand:
                    '$label,#${length.toRadixString(16).toUpperCase().padLeft(4, '0')}',
              );

              final baseLabelsLength = tree.labels.length;
              final baseNodesLength = tree.nodes.length;

              expect(output(symbol, tree), isNull);
              final expected = <Node>[
                // PUSH    0,GR1
                Node(0x7001),
                Node(0),
                // PUSH    0,GR2
                Node(0x7002),
                Node(0),
                // LAD     GR1,LABEL
                Node(0x1210),
                Node(0, Type.label),
                // LAD     GR2,LEN
                Node(0x1220),
                Node(length),
                // SVC     2
                Node(0xf000),
                Node(2),
                // POP     GR2
                Node(0x7120),
                // POP     GR1
                Node(0x7110),
              ];
              expect(symbol.nodes.length, equals(expected.length));
              expect(
                  tree.nodes.length, equals(baseNodesLength + expected.length));
              for (var i = 0; i < expected.length; i++) {
                expect(symbol.nodes[i].code, equals(expected[i].code));
                expect(symbol.nodes[i].type, equals(expected[i].type));
              }
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], isNotNull);
            });
          }
        });

        group('decimal,decimal', () {
          for (var i = 0; i < 8; i++) {
            test('$i', () {
              final addr = rand.nextInt(0x10000);
              final length = rand.nextInt(0x100);

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
                opecode: 'OUT',
                operand: '$addr,$length',
              );

              final baseLabelsLength = tree.labels.length;
              final baseNodesLength = tree.nodes.length;

              expect(output(symbol, tree), isNull);
              final expected = <Node>[
                // PUSH    0,GR1
                Node(0x7001),
                Node(0),
                // PUSH    0,GR2
                Node(0x7002),
                Node(0),
                // LAD     GR1,LABEL
                Node(0x1210),
                Node(addr),
                // LAD     GR2,LEN
                Node(0x1220),
                Node(length),
                // SVC     2
                Node(0xf000),
                Node(2),
                // POP     GR2
                Node(0x7120),
                // POP     GR1
                Node(0x7110),
              ];
              expect(symbol.nodes.length, equals(expected.length));
              expect(
                  tree.nodes.length, equals(baseNodesLength + expected.length));
              for (var i = 0; i < expected.length; i++) {
                expect(symbol.nodes[i].code, equals(expected[i].code));
                expect(symbol.nodes[i].type, equals(expected[i].type));
              }
              expect(tree.labels.length, equals(baseLabelsLength));
            });
          }
        });

        group('decimal,hex', () {
          for (var i = 0; i < 8; i++) {
            test('$i', () {
              final addr = rand.nextInt(0x10000);
              final length = rand.nextInt(0x100);

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
                opecode: 'OUT',
                operand:
                    '$addr,#${length.toRadixString(16).toUpperCase().padLeft(4, '0')}',
              );

              final baseLabelsLength = tree.labels.length;
              final baseNodesLength = tree.nodes.length;

              expect(output(symbol, tree), isNull);
              final expected = <Node>[
                // PUSH    0,GR1
                Node(0x7001),
                Node(0),
                // PUSH    0,GR2
                Node(0x7002),
                Node(0),
                // LAD     GR1,LABEL
                Node(0x1210),
                Node(addr),
                // LAD     GR2,LEN
                Node(0x1220),
                Node(length),
                // SVC     2
                Node(0xf000),
                Node(2),
                // POP     GR2
                Node(0x7120),
                // POP     GR1
                Node(0x7110),
              ];
              expect(symbol.nodes.length, equals(expected.length));
              expect(
                  tree.nodes.length, equals(baseNodesLength + expected.length));
              for (var i = 0; i < expected.length; i++) {
                expect(symbol.nodes[i].code, equals(expected[i].code));
                expect(symbol.nodes[i].type, equals(expected[i].type));
              }
              expect(tree.labels.length, equals(baseLabelsLength));
            });
          }
        });

        group('hex,decimal', () {
          for (var i = 0; i < 8; i++) {
            test('$i', () {
              final addr = rand.nextInt(0x10000);
              final length = rand.nextInt(0x100);

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
                opecode: 'OUT',
                operand:
                    '#${addr.toRadixString(16).toUpperCase().padLeft(4, '0')}'
                    ',$length',
              );

              final baseLabelsLength = tree.labels.length;
              final baseNodesLength = tree.nodes.length;

              expect(output(symbol, tree), isNull);
              final expected = <Node>[
                // PUSH    0,GR1
                Node(0x7001),
                Node(0),
                // PUSH    0,GR2
                Node(0x7002),
                Node(0),
                // LAD     GR1,LABEL
                Node(0x1210),
                Node(addr),
                // LAD     GR2,LEN
                Node(0x1220),
                Node(length),
                // SVC     2
                Node(0xf000),
                Node(2),
                // POP     GR2
                Node(0x7120),
                // POP     GR1
                Node(0x7110),
              ];
              expect(symbol.nodes.length, equals(expected.length));
              expect(
                  tree.nodes.length, equals(baseNodesLength + expected.length));
              for (var i = 0; i < expected.length; i++) {
                expect(symbol.nodes[i].code, equals(expected[i].code));
                expect(symbol.nodes[i].type, equals(expected[i].type));
              }
              expect(tree.labels.length, equals(baseLabelsLength));
            });
          }
        });

        group('hex,hex', () {
          for (var i = 0; i < 8; i++) {
            test('$i', () {
              final addr = rand.nextInt(0x10000);
              final length = rand.nextInt(0x100);

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
                opecode: 'OUT',
                operand:
                    '#${addr.toRadixString(16).toUpperCase().padLeft(4, '0')}'
                    ',#${length.toRadixString(16).toUpperCase().padLeft(4, '0')}',
              );

              final baseLabelsLength = tree.labels.length;
              final baseNodesLength = tree.nodes.length;

              expect(output(symbol, tree), isNull);
              final expected = <Node>[
                // PUSH    0,GR1
                Node(0x7001),
                Node(0),
                // PUSH    0,GR2
                Node(0x7002),
                Node(0),
                // LAD     GR1,LABEL
                Node(0x1210),
                Node(addr),
                // LAD     GR2,LEN
                Node(0x1220),
                Node(length),
                // SVC     2
                Node(0xf000),
                Node(2),
                // POP     GR2
                Node(0x7120),
                // POP     GR1
                Node(0x7110),
              ];
              expect(symbol.nodes.length, equals(expected.length));
              expect(
                  tree.nodes.length, equals(baseNodesLength + expected.length));
              for (var i = 0; i < expected.length; i++) {
                expect(symbol.nodes[i].code, equals(expected[i].code));
                expect(symbol.nodes[i].type, equals(expected[i].type));
              }
              expect(tree.labels.length, equals(baseLabelsLength));
            });
          }
        });
      });

      group('with label', () {
        group('label,decimal', () {
          for (var i = 0; i < 8; i++) {
            test('$i', () {
              final insLabel = 'READ$i';
              final label =
                  'BUF${rand.nextInt(0x100).toRadixString(16).toUpperCase().padLeft(2, '0')}';
              final length = rand.nextInt(0x100);

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
                label: insLabel,
                opecode: 'OUT',
                operand: '$label,$length',
              );

              final baseLabelsLength = tree.labels.length;
              final baseNodesLength = tree.nodes.length;

              expect(output(symbol, tree), isNull);
              final expected = <Node>[
                // PUSH    0,GR1
                Node(0x7001),
                Node(0),
                // PUSH    0,GR2
                Node(0x7002),
                Node(0),
                // LAD     GR1,LABEL
                Node(0x1210),
                Node(0, Type.label),
                // LAD     GR2,LEN
                Node(0x1220),
                Node(length),
                // SVC     2
                Node(0xf000),
                Node(2),
                // POP     GR2
                Node(0x7120),
                // POP     GR1
                Node(0x7110),
              ];
              expect(symbol.nodes.length, equals(expected.length));
              expect(
                  tree.nodes.length, equals(baseNodesLength + expected.length));
              for (var i = 0; i < expected.length; i++) {
                expect(symbol.nodes[i].code, equals(expected[i].code));
                expect(symbol.nodes[i].type, equals(expected[i].type));
              }
              expect(tree.labels.length, equals(baseLabelsLength + 2));
              expect(tree.labels[label], isNotNull);
              expect(tree.labels[insLabel], isNotNull);
            });
          }
        });

        group('label,hex', () {
          for (var i = 0; i < 8; i++) {
            test('$i', () {
              final insLabel = 'READ$i';
              final label =
                  'BUF${rand.nextInt(0x100).toRadixString(16).toUpperCase().padLeft(2, '0')}';
              final length = rand.nextInt(0x100);

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
                label: insLabel,
                opecode: 'OUT',
                operand:
                    '$label,#${length.toRadixString(16).toUpperCase().padLeft(4, '0')}',
              );

              final baseLabelsLength = tree.labels.length;
              final baseNodesLength = tree.nodes.length;

              expect(output(symbol, tree), isNull);
              final expected = <Node>[
                // PUSH    0,GR1
                Node(0x7001),
                Node(0),
                // PUSH    0,GR2
                Node(0x7002),
                Node(0),
                // LAD     GR1,LABEL
                Node(0x1210),
                Node(0, Type.label),
                // LAD     GR2,LEN
                Node(0x1220),
                Node(length),
                // SVC     2
                Node(0xf000),
                Node(2),
                // POP     GR2
                Node(0x7120),
                // POP     GR1
                Node(0x7110),
              ];
              expect(symbol.nodes.length, equals(expected.length));
              expect(
                  tree.nodes.length, equals(baseNodesLength + expected.length));
              for (var i = 0; i < expected.length; i++) {
                expect(symbol.nodes[i].code, equals(expected[i].code));
                expect(symbol.nodes[i].type, equals(expected[i].type));
              }
              expect(tree.labels.length, equals(baseLabelsLength + 2));
              expect(tree.labels[label], isNotNull);
              expect(tree.labels[insLabel], isNotNull);
            });
          }
        });

        group('decimal,decimal', () {
          for (var i = 0; i < 8; i++) {
            test('$i', () {
              final label = 'READ$i';
              final addr = rand.nextInt(0x10000);
              final length = rand.nextInt(0x100);

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
                opecode: 'OUT',
                operand: '$addr,$length',
              );

              final baseLabelsLength = tree.labels.length;
              final baseNodesLength = tree.nodes.length;

              expect(output(symbol, tree), isNull);
              final expected = <Node>[
                // PUSH    0,GR1
                Node(0x7001),
                Node(0),
                // PUSH    0,GR2
                Node(0x7002),
                Node(0),
                // LAD     GR1,LABEL
                Node(0x1210),
                Node(addr),
                // LAD     GR2,LEN
                Node(0x1220),
                Node(length),
                // SVC     2
                Node(0xf000),
                Node(2),
                // POP     GR2
                Node(0x7120),
                // POP     GR1
                Node(0x7110),
              ];
              expect(symbol.nodes.length, equals(expected.length));
              expect(
                  tree.nodes.length, equals(baseNodesLength + expected.length));
              for (var i = 0; i < expected.length; i++) {
                expect(symbol.nodes[i].code, equals(expected[i].code));
                expect(symbol.nodes[i].type, equals(expected[i].type));
              }
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], isNotNull);
            });
          }
        });

        group('decimal,hex', () {
          for (var i = 0; i < 8; i++) {
            test('$i', () {
              final label = 'READ$i';
              final addr = rand.nextInt(0x10000);
              final length = rand.nextInt(0x100);

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
                opecode: 'OUT',
                operand:
                    '$addr,#${length.toRadixString(16).toUpperCase().padLeft(4, '0')}',
              );

              final baseLabelsLength = tree.labels.length;
              final baseNodesLength = tree.nodes.length;

              expect(output(symbol, tree), isNull);
              final expected = <Node>[
                // PUSH    0,GR1
                Node(0x7001),
                Node(0),
                // PUSH    0,GR2
                Node(0x7002),
                Node(0),
                // LAD     GR1,LABEL
                Node(0x1210),
                Node(addr),
                // LAD     GR2,LEN
                Node(0x1220),
                Node(length),
                // SVC     2
                Node(0xf000),
                Node(2),
                // POP     GR2
                Node(0x7120),
                // POP     GR1
                Node(0x7110),
              ];
              expect(symbol.nodes.length, equals(expected.length));
              expect(
                  tree.nodes.length, equals(baseNodesLength + expected.length));
              for (var i = 0; i < expected.length; i++) {
                expect(symbol.nodes[i].code, equals(expected[i].code));
                expect(symbol.nodes[i].type, equals(expected[i].type));
              }
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], isNotNull);
            });
          }
        });

        group('hex,decimal', () {
          for (var i = 0; i < 8; i++) {
            test('$i', () {
              final label = 'READ$i';
              final addr = rand.nextInt(0x10000);
              final length = rand.nextInt(0x100);

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
                opecode: 'OUT',
                operand:
                    '#${addr.toRadixString(16).toUpperCase().padLeft(4, '0')}'
                    ',$length',
              );

              final baseLabelsLength = tree.labels.length;
              final baseNodesLength = tree.nodes.length;

              expect(output(symbol, tree), isNull);
              final expected = <Node>[
                // PUSH    0,GR1
                Node(0x7001),
                Node(0),
                // PUSH    0,GR2
                Node(0x7002),
                Node(0),
                // LAD     GR1,LABEL
                Node(0x1210),
                Node(addr),
                // LAD     GR2,LEN
                Node(0x1220),
                Node(length),
                // SVC     2
                Node(0xf000),
                Node(2),
                // POP     GR2
                Node(0x7120),
                // POP     GR1
                Node(0x7110),
              ];
              expect(symbol.nodes.length, equals(expected.length));
              expect(
                  tree.nodes.length, equals(baseNodesLength + expected.length));
              for (var i = 0; i < expected.length; i++) {
                expect(symbol.nodes[i].code, equals(expected[i].code));
                expect(symbol.nodes[i].type, equals(expected[i].type));
              }
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], isNotNull);
            });
          }
        });

        group('hex,hex', () {
          for (var i = 0; i < 8; i++) {
            test('$i', () {
              final label = 'READ$i';
              final addr = rand.nextInt(0x10000);
              final length = rand.nextInt(0x100);

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
                opecode: 'OUT',
                operand:
                    '#${addr.toRadixString(16).toUpperCase().padLeft(4, '0')}'
                    ',#${length.toRadixString(16).toUpperCase().padLeft(4, '0')}',
              );

              final baseLabelsLength = tree.labels.length;
              final baseNodesLength = tree.nodes.length;

              expect(output(symbol, tree), isNull);
              final expected = <Node>[
                // PUSH    0,GR1
                Node(0x7001),
                Node(0),
                // PUSH    0,GR2
                Node(0x7002),
                Node(0),
                // LAD     GR1,LABEL
                Node(0x1210),
                Node(addr),
                // LAD     GR2,LEN
                Node(0x1220),
                Node(length),
                // SVC     2
                Node(0xf000),
                Node(2),
                // POP     GR2
                Node(0x7120),
                // POP     GR1
                Node(0x7110),
              ];
              expect(symbol.nodes.length, equals(expected.length));
              expect(
                  tree.nodes.length, equals(baseNodesLength + expected.length));
              for (var i = 0; i < expected.length; i++) {
                expect(symbol.nodes[i].code, equals(expected[i].code));
                expect(symbol.nodes[i].type, equals(expected[i].type));
              }
              expect(tree.labels.length, equals(baseLabelsLength + 1));
              expect(tree.labels[label], isNotNull);
            });
          }
        });
      });
    });
  });
}
