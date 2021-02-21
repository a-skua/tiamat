import 'token.dart';
import 'symbol.dart';

List<Symbol> symbolize(List<Token> tokens) {
  final symbols = <Symbol>[];

  final comment = <int>[];
  final label = <int>[];
  final opecode = <int>[];
  final operand = <int>[];

  for (final token in tokens) {
    switch (token.type) {
      case TokenType.comment:
        comment.add(token.rune);
        break;
      case TokenType.label:
        label.add(token.rune);
        break;
      case TokenType.opecode:
        opecode.add(token.rune);
        break;
      case TokenType.operand:
        operand.add(token.rune);
        break;
      case TokenType.endLine:
        symbols.add(Symbol(
          comment: List.of(comment),
          label: List.of(label),
          opecode: List.of(opecode),
          operand: List.of(operand),
        ));
        comment.clear();
        label.clear();
        opecode.clear();
        operand.clear();
        break;
    }
  }
  if (comment.isNotEmpty ||
      label.isNotEmpty ||
      opecode.isNotEmpty ||
      operand.isNotEmpty) {
    symbols.add(Symbol(
      comment: comment,
      label: label,
      opecode: opecode,
      operand: operand,
    ));
  }
  return symbols;
}
