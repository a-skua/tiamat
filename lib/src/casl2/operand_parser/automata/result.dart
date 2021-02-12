import '../../core/node.dart';

/// Error.
class Error {}

/// Interface.
class Result<T> {
  /// Set last state.
  final T lastState;

  /// Set error when has error.
  final Error? error;

  /// Set result values.
  final List<Node> values;

  Result(
    this.values,
    this.lastState, {
    this.error = null,
  });

  bool get hasError => this.error != null;
  bool get hasNotError => !this.hasError;
}
