import '../token/token.dart';
import '../token/parser.dart';
import 'node.dart' show Root;

List<Root> token2root(List<Token> tokens) {
  final nodes = <Root>[];

  final comment = <int>[];
  final label = <int>[];
  final instruction = <int>[];
  final operand = <int>[];

  for (final token in tokens) {
    switch (token.type) {
      case Type.comment:
        comment.add(token.rune);
        break;
      case Type.label:
        label.add(token.rune);
        break;
      case Type.instruction:
        instruction.add(token.rune);
        break;
      case Type.operand:
        operand.add(token.rune);
        break;
      case Type.endLine:
        if (comment.isEmpty &&
            label.isEmpty &&
            instruction.isEmpty &&
            operand.isEmpty) {
          break;
        }
        nodes.add(Root(
          comment: String.fromCharCodes(comment),
          label: String.fromCharCodes(label),
          instruction: String.fromCharCodes(instruction),
          operand: String.fromCharCodes(operand),
        ));
        comment.clear();
        label.clear();
        instruction.clear();
        operand.clear();
        break;
    }
  }
  if (comment.isEmpty &&
      label.isEmpty &&
      instruction.isEmpty &&
      operand.isEmpty) {
    return nodes;
  }
  nodes.add(Root(
    comment: String.fromCharCodes(comment),
    label: String.fromCharCodes(label),
    instruction: String.fromCharCodes(instruction),
    operand: String.fromCharCodes(operand),
  ));
  return nodes;
}
