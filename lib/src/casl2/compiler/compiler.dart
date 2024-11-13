import '../../typedef/typedef.dart';

final class CompileError {}

abstract class Compiler {
  /// Compile the source code.
  Result<void, CompileError> compile(String source);
}
