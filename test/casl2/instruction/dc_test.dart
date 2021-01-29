import 'dart:math';

import 'package:tiamat/src/casl2/instruction/dc.dart';
import 'package:tiamat/src/casl2/node/node.dart';
import 'package:tiamat/src/util/charcode.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  group('dc', () {
    test('a string', () {
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
        comment: 'string test',
        label: 'BUF',
        instruction: 'DC',
        operand: "'hello, world'",
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      final expecteds = 'hello, world'.split('');

      dc(root, tree);
      expect(tree.nodes.length, equals(baseNodesLength + expecteds.length));
      expect(tree.labels.length, equals(baseLabelsLength + 1));
      expect(root.nodes.length, equals(expecteds.length));

      for (var i = 0; i < expecteds.length; i++) {
        expect(root.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(root.nodes[i].type, equals(Type.code));
        expect(root.nodes[i].code, equals(char2code[expecteds[i]]));
      }
      expect(tree.labels['BUF'], isNot(equals(null)));
      expect(tree.labels['BUF']?.entity, equals(root.nodes.first));
    });

    test('multiple string', () {
      final tree = Tree()
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
      final root = Root(
        comment: 'strings test',
        label: '',
        instruction: 'DC',
        operand: "'hello, world!','it''s a small world!'",
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      final expecteds = "hello, world!it's a small world!".split('');

      dc(root, tree);
      expect(tree.nodes.length, equals(baseNodesLength + expecteds.length));
      expect(tree.labels.length, equals(baseLabelsLength));
      expect(root.nodes.length, expecteds.length);
      for (var i = 0; i < expecteds.length; i++) {
        expect(root.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(root.nodes[i].type, equals(Type.code));
        expect(root.nodes[i].code, equals(char2code[expecteds[i]]));
      }
    });

    test('an address', () {
      final tree = Tree()
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
      final root = Root(
        comment: 'an address test',
        label: 'NUM',
        instruction: 'DC',
        operand: '-1',
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      final expecteds = <int>[-1];

      dc(root, tree);
      expect(tree.nodes.length, equals(baseNodesLength + expecteds.length));
      expect(tree.labels.length, equals(baseLabelsLength + 1));
      expect(root.nodes.length, expecteds.length);
      for (var i = 0; i < expecteds.length; i++) {
        expect(root.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(root.nodes[i].type, equals(Type.code));
        expect(root.nodes[i].code, equals(expecteds[i]));
      }
      expect(tree.labels['NUM'], isNot(equals(null)));
      expect(tree.labels['NUM']?.entity, equals(root.nodes.first));
    });

    test('multiple address', () {
      final tree = Tree()
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
      final root = Root(
        comment: 'an address test',
        label: '',
        instruction: 'DC',
        operand: "124,-1,-234,657",
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      final expecteds = <int>[124, -1, -234, 657];

      dc(root, tree);
      expect(tree.nodes.length, equals(baseNodesLength + expecteds.length));
      expect(tree.labels.length, equals(baseLabelsLength));
      expect(root.nodes.length, expecteds.length);
      for (var i = 0; i < expecteds.length; i++) {
        expect(root.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(root.nodes[i].type, equals(Type.code));
        expect(root.nodes[i].code, equals(expecteds[i]));
      }
    });

    test('a hex address', () {
      final tree = Tree()
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
      final root = Root(
        comment: 'an address test',
        label: 'HEX',
        instruction: 'DC',
        operand: '#FFFF',
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      final expecteds = <int>[0xffff];

      dc(root, tree);
      expect(tree.nodes.length, equals(baseNodesLength + expecteds.length));
      expect(tree.labels.length, equals(baseLabelsLength + 1));
      expect(root.nodes.length, expecteds.length);
      for (var i = 0; i < expecteds.length; i++) {
        expect(root.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(root.nodes[i].type, equals(Type.code));
        expect(root.nodes[i].code, equals(expecteds[i]));
      }
      expect(tree.labels['HEX'], isNot(equals(null)));
      expect(tree.labels['HEX']?.entity, equals(root.nodes.first));
    });

    test('multiple hex address', () {
      final tree = Tree()
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
      final root = Root(
        comment: 'an address test',
        label: '',
        instruction: 'DC',
        operand: '#1234,#ABCD,#0F9A',
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      final expecteds = <int>[0x1234, 0xabcd, 0x0f9a];

      dc(root, tree);
      expect(tree.nodes.length, equals(baseNodesLength + expecteds.length));
      expect(tree.labels.length, equals(baseLabelsLength));
      expect(root.nodes.length, expecteds.length);
      for (var i = 0; i < expecteds.length; i++) {
        expect(root.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(root.nodes[i].type, equals(Type.code));
        expect(root.nodes[i].code, equals(expecteds[i]));
      }
    });

    test('a label', () {
      final tree = Tree()
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
      final root = Root(
        comment: 'an address test',
        label: 'LBL',
        instruction: 'DC',
        operand: 'BUF',
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      final expecteds = <String>['BUF'];

      dc(root, tree);
      expect(tree.nodes.length, equals(baseNodesLength + expecteds.length));
      expect(
          tree.labels.length, equals(baseLabelsLength + expecteds.length + 1));
      expect(root.nodes.length, expecteds.length);
      for (var i = 0; i < expecteds.length; i++) {
        expect(root.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(root.nodes[i].type, equals(Type.label));
        expect(tree.labels[expecteds[i]], isNot(equals(null)));
        expect(tree.labels[expecteds[i]]?.entity, equals(null));
        expect(tree.labels[expecteds[i]]?.references.length, equals(1));
        expect(tree.labels[expecteds[i]]?.references[0], equals(root.nodes[i]));
      }
      expect(tree.labels['LBL'], isNot(equals(null)));
      expect(tree.labels['LBL']?.entity, equals(root.nodes.first));
    });

    test('multiple label', () {
      final tree = Tree()
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
      final root = Root(
        comment: 'an address test',
        label: 'LBL',
        instruction: 'DC',
        operand: 'FIZZ,BUZZ,X68000',
      );

      final baseLabelsLength = tree.labels.length;
      final baseNodesLength = tree.nodes.length;
      final expecteds = <String>['FIZZ', 'BUZZ', 'X68000'];

      dc(root, tree);
      expect(tree.nodes.length, equals(baseNodesLength + expecteds.length));
      expect(
          tree.labels.length, equals(baseLabelsLength + expecteds.length + 1));
      expect(root.nodes.length, expecteds.length);
      for (var i = 0; i < expecteds.length; i++) {
        expect(root.nodes[i], equals(tree.nodes[baseNodesLength + i]));
        expect(root.nodes[i].type, equals(Type.label));
        expect(tree.labels[expecteds[i]], isNot(equals(null)));
        expect(tree.labels[expecteds[i]]?.entity, equals(null));
        expect(tree.labels[expecteds[i]]?.references.length, equals(1));
        expect(tree.labels[expecteds[i]]?.references[0], equals(root.nodes[i]));
      }
    });
  });
}
