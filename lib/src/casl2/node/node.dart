/// Node type.
enum Type {
  label,
  code,
}

/// Node.
class Node {
  int _code;
  Type _type;

  /// New instance.
  ///
  /// Arguments
  /// 1. int code
  /// 2. node type
  Node(this._code, this._type);

  /// Get code.
  int get code => this._code;

  /// Get type.
  Type get type => this._type;

  /// Set code.
  ///
  /// Set the code only once when the type is label,
  /// change the type to code aflter setted.
  void set code(int c) {
    if (this.type == Type.label) {
      this._type = Type.code;
      this._code = c;
    }
  }
}

/// Root node.
class Root {
  final String comment;
  final String label;
  final String instruction;
  final String operand;

  /// To code from casl2.
  final nodes = <Node>[];

  Root({
    required this.comment,
    required this.label,
    required this.instruction,
    required this.operand,
  });
}
