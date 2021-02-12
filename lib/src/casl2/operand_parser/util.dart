import '../core/node.dart';
import '../core/node_tree.dart';

void setLabel(
  final String label,
  final Node node,
  final Map<String, Label> map,
) {
  if (label.isEmpty) {
    return;
  }
  if (map[label] == null) {
    map[label] = Label();
  }
  map[label]?.entity = node;
}

void addReferenceLabel(
  final String label,
  final Node node,
  final Map<String, Label> map,
) {
  if (map[label] == null) {
    map[label] = Label();
  }
  map[label]?.references?.add(node);
}
