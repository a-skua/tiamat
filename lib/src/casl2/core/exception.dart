import 'error.dart';

/// CASL2's compiled exception
class CompileException {
  final List<Error> _errors;

  CompileException(this._errors);

  String toString() {
    var str = 'failed compile.\n';
    for (final error in this._errors) {
      str += error.detail + '\n';
    }
    return str;
  }
}
