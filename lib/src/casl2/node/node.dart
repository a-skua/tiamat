/// Node type.
enum Type {
  label,
  code,
}

/// Node.
class Node {
  int _code;
  Type _type;
  final String _label;

  /// New instance.
  ///
  /// Arguments
  /// 1. int code
  /// 2. node type
  /// 3. label(optional)
  Node(this._code, this._type, [this._label = '']);

  /// Get label when type is label.
  String get label => this.type == Type.label ? this._label : '';

  /// Get code.
  int get code => this._code;

  /// Get type.
  Type get type => this._type;

  /// Set the code only once when type is label.
  void set code(int c) {
    if (this.type == Type.label) {
      this._type = Type.code;
      this._code = c;
    }
  }
}

/// Root node.
class RootNode {
  final String comment;
  final String label;
  final String instruction;
  final String operand;

  /// To code from casl2.
  final children = <Node>[];

  RootNode({
    required this.comment,
    required this.label,
    required this.instruction,
    required this.operand,
  });
}
