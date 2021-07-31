import 'node.dart';

/// Symbol
class Symbol {
  /// comment is near type Runes.
  final List<int> comment;

  /// label is near type Runes.
  final List<int> label;

  /// opecode is near type Runes.
  final List<int> opecode;

  /// operand is near type Runes.
  final List<int> operand;

  /// To code from casl2.
  final nodes = <Node>[];

  Symbol({
    this.comment = const [],
    this.label = const [],
    this.opecode = const [],
    this.operand = const [],
  });

  factory Symbol.fromString({
    comment = '',
    label = '',
    opecode = '',
    operand = '',
  }) {
    return Symbol(
      comment: comment.runes.toList(),
      label: label.runes.toList(),
      opecode: opecode.runes.toList(),
      operand: operand.runes.toList(),
    );
  }

  String toString() {
    final label =
        this.label.isEmpty ? '' : '[${String.fromCharCodes(this.label)}]';
    final opecode = String.fromCharCodes(this.opecode);
    final operand = String.fromCharCodes(this.operand);
    return '$label $opecode $operand: ${this.nodes}';
  }
}
