import 'dart:math';

import 'package:tiamat/src/casl2/operand_parser/dc.dart';
import 'package:tiamat/src/casl2/core/node.dart';
import 'package:tiamat/src/casl2/core/node_tree.dart';
import 'package:tiamat/src/casl2/core/symbol.dart';
import 'package:tiamat/src/util/charcode.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('dc', () {
    test('a string', () {
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
        comment: 'string test',
        label: 'BUF',
        opecode: 'DC',
        operand: "'hello, world'",
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      final expecteds = 'hello, world'.split('');

      dc(symbol, tree);
      expect(tree.nodes.length, equals(baseNodesLength + expecteds.length));
      expect(tree.labels.length, equals(baseLabelsLength + 1));
      expect(symbol.nodes.length, equals(expecteds.length));

      for (var i = 0; i < expecteds.length; i++) {
        expect(symbol.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(symbol.nodes[i].type, equals(Type.code));
        expect(symbol.nodes[i].code, equals(char2code[expecteds[i]]));
      }
      expect(tree.labels['BUF'], isNot(equals(null)));
      expect(tree.labels['BUF']?.entity, equals(symbol.nodes.first));
    });

    test('multiple string', () {
      final tree = NodeTree()
        ..nodes.addAll(List.generate(
          rand.nextInt(0x100),
          (_) => Node(rand.nextInt(0x10000)),
        ));
      {
        final length = rand.nextInt(0x100);
        tree.labels.addAll(Map.fromIterables(
          List.generate(length, (i) => '$i${rand.nextInt(0x10000)}'),
          List.generate(length, (_) => Label()),
        ));
      }
      final symbol = Symbol.fromString(
        comment: 'strings test',
        label: '',
        opecode: 'DC',
        operand: "'hello, world!','it''s a small world!'",
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      final expecteds = "hello, world!it's a small world!".split('');

      dc(symbol, tree);
      expect(tree.nodes.length, equals(baseNodesLength + expecteds.length));
      expect(tree.labels.length, equals(baseLabelsLength));
      expect(symbol.nodes.length, expecteds.length);
      for (var i = 0; i < expecteds.length; i++) {
        expect(symbol.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(symbol.nodes[i].type, equals(Type.code));
        expect(symbol.nodes[i].code, equals(char2code[expecteds[i]]));
      }
    });

    test('an address', () {
      final tree = NodeTree()
        ..nodes.addAll(List.generate(
          rand.nextInt(0x100),
          (_) => Node(rand.nextInt(0x10000)),
        ));
      {
        final length = rand.nextInt(0x100);
        tree.labels.addAll(Map.fromIterables(
          List.generate(length, (i) => '$i${rand.nextInt(0x10000)}'),
          List.generate(length, (_) => Label()),
        ));
      }
      final symbol = Symbol.fromString(
        comment: 'an address test',
        label: 'NUM',
        opecode: 'DC',
        operand: '-1',
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      final expecteds = <int>[-1];

      dc(symbol, tree);
      expect(tree.nodes.length, equals(baseNodesLength + expecteds.length));
      expect(tree.labels.length, equals(baseLabelsLength + 1));
      expect(symbol.nodes.length, expecteds.length);
      for (var i = 0; i < expecteds.length; i++) {
        expect(symbol.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(symbol.nodes[i].type, equals(Type.code));
        expect(symbol.nodes[i].code, equals(expecteds[i]));
      }
      expect(tree.labels['NUM'], isNot(equals(null)));
      expect(tree.labels['NUM']?.entity, equals(symbol.nodes.first));
    });

    test('multiple address', () {
      final tree = NodeTree()
        ..nodes.addAll(List.generate(
          rand.nextInt(0x100),
          (_) => Node(rand.nextInt(0x10000)),
        ));
      {
        final length = rand.nextInt(0x100);
        tree.labels.addAll(Map.fromIterables(
          List.generate(length, (i) => '$i${rand.nextInt(0x10000)}'),
          List.generate(length, (_) => Label()),
        ));
      }
      final symbol = Symbol.fromString(
        comment: 'an address test',
        label: '',
        opecode: 'DC',
        operand: "124,-1,-234,657",
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      final expecteds = <int>[124, -1, -234, 657];

      dc(symbol, tree);
      expect(tree.nodes.length, equals(baseNodesLength + expecteds.length));
      expect(tree.labels.length, equals(baseLabelsLength));
      expect(symbol.nodes.length, expecteds.length);
      for (var i = 0; i < expecteds.length; i++) {
        expect(symbol.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(symbol.nodes[i].type, equals(Type.code));
        expect(symbol.nodes[i].code, equals(expecteds[i]));
      }
    });

    test('a hex address', () {
      final tree = NodeTree()
        ..nodes.addAll(List.generate(
          rand.nextInt(0x100),
          (_) => Node(rand.nextInt(0x10000)),
        ));
      {
        final length = rand.nextInt(0x100);
        tree.labels.addAll(Map.fromIterables(
          List.generate(length, (i) => '$i${rand.nextInt(0x10000)}'),
          List.generate(length, (_) => Label()),
        ));
      }
      final symbol = Symbol.fromString(
        comment: 'an address test',
        label: 'HEX',
        opecode: 'DC',
        operand: '#FFFF',
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      final expecteds = <int>[0xffff];

      dc(symbol, tree);
      expect(tree.nodes.length, equals(baseNodesLength + expecteds.length));
      expect(tree.labels.length, equals(baseLabelsLength + 1));
      expect(symbol.nodes.length, expecteds.length);
      for (var i = 0; i < expecteds.length; i++) {
        expect(symbol.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(symbol.nodes[i].type, equals(Type.code));
        expect(symbol.nodes[i].code, equals(expecteds[i]));
      }
      expect(tree.labels['HEX'], isNot(equals(null)));
      expect(tree.labels['HEX']?.entity, equals(symbol.nodes.first));
    });

    test('multiple hex address', () {
      final tree = NodeTree()
        ..nodes.addAll(List.generate(
          rand.nextInt(0x100),
          (_) => Node(rand.nextInt(0x10000)),
        ));
      {
        final length = rand.nextInt(0x100);
        tree.labels.addAll(Map.fromIterables(
          List.generate(length, (i) => '$i${rand.nextInt(0x10000)}'),
          List.generate(length, (_) => Label()),
        ));
      }
      final symbol = Symbol.fromString(
        comment: 'an address test',
        label: '',
        opecode: 'DC',
        operand: '#1234,#ABCD,#0F9A',
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      final expecteds = <int>[0x1234, 0xabcd, 0x0f9a];

      dc(symbol, tree);
      expect(tree.nodes.length, equals(baseNodesLength + expecteds.length));
      expect(tree.labels.length, equals(baseLabelsLength));
      expect(symbol.nodes.length, expecteds.length);
      for (var i = 0; i < expecteds.length; i++) {
        expect(symbol.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(symbol.nodes[i].type, equals(Type.code));
        expect(symbol.nodes[i].code, equals(expecteds[i]));
      }
    });

    test('a label', () {
      final tree = NodeTree()
        ..nodes.addAll(List.generate(
          rand.nextInt(0x100),
          (_) => Node(rand.nextInt(0x10000)),
        ));
      {
        final length = rand.nextInt(0x100);
        tree.labels.addAll(Map.fromIterables(
          List.generate(length, (i) => '$i${rand.nextInt(0x10000)}'),
          List.generate(length, (_) => Label()),
        ));
      }
      final symbol = Symbol.fromString(
        comment: 'an address test',
        label: 'LBL',
        opecode: 'DC',
        operand: 'BUF',
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      final expecteds = <String>['BUF'];

      dc(symbol, tree);
      expect(tree.nodes.length, equals(baseNodesLength + expecteds.length));
      expect(
          tree.labels.length, equals(baseLabelsLength + expecteds.length + 1));
      expect(symbol.nodes.length, expecteds.length);
      for (var i = 0; i < expecteds.length; i++) {
        expect(symbol.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(symbol.nodes[i].type, equals(Type.label));
        expect(tree.labels[expecteds[i]], isNot(equals(null)));
        expect(tree.labels[expecteds[i]]?.entity, equals(null));
        expect(tree.labels[expecteds[i]]?.references.length, equals(1));
        expect(
            tree.labels[expecteds[i]]?.references[0], equals(symbol.nodes[i]));
      }
      expect(tree.labels['LBL'], isNot(equals(null)));
      expect(tree.labels['LBL']?.entity, equals(symbol.nodes.first));
    });

    test('multiple label', () {
      final tree = NodeTree()
        ..nodes.addAll(List.generate(
          rand.nextInt(0x100),
          (_) => Node(rand.nextInt(0x10000)),
        ));
      {
        final length = rand.nextInt(0x100);
        tree.labels.addAll(Map.fromIterables(
          List.generate(length, (i) => '$i${rand.nextInt(0x10000)}'),
          List.generate(length, (_) => Label()),
        ));
      }
      final symbol = Symbol.fromString(
        comment: 'an address test',
        label: 'LBL',
        opecode: 'DC',
        operand: 'FIZZ,BUZZ,X68000',
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      final expecteds = <String>['FIZZ', 'BUZZ', 'X68000'];

      dc(symbol, tree);
      expect(tree.nodes.length, equals(baseNodesLength + expecteds.length));
      expect(
          tree.labels.length, equals(baseLabelsLength + expecteds.length + 1));
      expect(symbol.nodes.length, expecteds.length);
      for (var i = 0; i < expecteds.length; i++) {
        expect(symbol.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(symbol.nodes[i].type, equals(Type.label));
        expect(tree.labels[expecteds[i]], isNot(equals(null)));
        expect(tree.labels[expecteds[i]]?.entity, equals(null));
        expect(tree.labels[expecteds[i]]?.references.length, equals(1));
        expect(
            tree.labels[expecteds[i]]?.references[0], equals(symbol.nodes[i]));
      }
    });
  });
}
