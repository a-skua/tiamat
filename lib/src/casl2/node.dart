import 'token.dart' as token;

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

  for (final t in token.parse(s)) {
    switch (t.state) {
      case token.State.comment:
        comment.add(t.rune);
        break;
      case token.State.label:
        label.add(t.rune);
        break;
      case token.State.instruction:
        instruction.add(t.rune);
        break;
      case token.State.operand:
        operand.add(t.rune);
        break;
      case token.State.newline:
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
