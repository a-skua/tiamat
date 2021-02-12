import 'node.dart';

/// Label.
class Label {
  Node? entity;
  final references = <Node>[];
}

/// NodeTree.
class NodeTree {
  // START LABEL.
  String startLabel = '';

  /// Labels.
  final labels = <String, Label>{};

  /// Nodes.
  final nodes = <Node>[];
}
