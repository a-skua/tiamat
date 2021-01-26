import '../node/node.dart';

void setLabel(
    final String label, final Node node, final Map<String, Label> map) {
  if (label.isEmpty) {
    return;
  }
  map[label] = Label()..entity = node;
}

void addReferenceLabel(
    final String label, final Node node, final Map<String, Label> map) {
  if (map[label] == null) {
    map[label] = Label()..references.add(node);
  } else {
    map[label]?.references?.add(node);
  }
}
