import 'token/token.dart' as token;
import 'token/parser.dart' as tokenParser;

class Node {
  final String comment;
  final String label;
  final String instruction;
  final String operand;

  Node({
    required this.comment,
    required this.label,
    required this.instruction,
    required this.operand,
  });
}

List<Node> parse(String s) {
  final nodes = <Node>[];

  final comment = <int>[];
  final label = <int>[];
  final instruction = <int>[];
  final operand = <int>[];

  for (final t in tokenParser.parse(s)) {
    switch (t.type) {
      case token.Type.comment:
        comment.add(t.rune);
        break;
      case token.Type.label:
        label.add(t.rune);
        break;
      case token.Type.instruction:
        instruction.add(t.rune);
        break;
      case token.Type.operand:
        operand.add(t.rune);
        break;
      case token.Type.endLine:
        if (comment.isNotEmpty ||
            label.isNotEmpty ||
            instruction.isNotEmpty ||
            operand.isNotEmpty) {
          nodes.add(Node(
            comment: String.fromCharCodes(comment),
            label: String.fromCharCodes(label),
            instruction: String.fromCharCodes(instruction),
            operand: String.fromCharCodes(operand),
          ));
          comment.clear();
          label.clear();
          instruction.clear();
          operand.clear();
        }
        break;
    }
  }
  if (comment.isNotEmpty ||
      label.isNotEmpty ||
      instruction.isNotEmpty ||
      operand.isNotEmpty) {
    nodes.add(Node(
      comment: String.fromCharCodes(comment),
      label: String.fromCharCodes(label),
      instruction: String.fromCharCodes(instruction),
      operand: String.fromCharCodes(operand),
    ));
  }
  return nodes;
}
