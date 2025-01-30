import '../typedef/result.dart';
import './lexer/token.dart' show Token;
import './compiler/compiler.dart' show CompileError;

/// Dart [Rune]
typedef Rune = int;

/// [Real] [Word]
typedef Real = int;

/// [Address] [Real] Word
typedef Address = int;

typedef Label = String;
typedef Resolve = Address? Function(Label label);

/// [Word] of COMET2
sealed class Word {
  const Word();

  List<Label> get labels;

  Result<Real, CompileError> real(Resolve resolve);

  @override
  String toString() => throw UnimplementedError();
}

/// [Constant] of [Word]
final class Constant extends Word {
  final Real _real;

  @override
  final List<Label> labels;

  const Constant(this._real, this.labels) : super();

  @override
  Result<Real, CompileError> real(Resolve resolve) => Ok(_real);

  @override
  String toString() => 'CONST($_real)';
}

final class Reference extends Word {
  final Token _label;

  @override
  final List<Label> labels;

  const Reference(this._label, this.labels) : super();

  @override
  Result<Real, CompileError> real(Resolve resolve) {
    final addr = resolve(_label.string);
    if (addr == null) {
      return Err(CompileError.fromToken(
        '[ERROR] UNKNOWN LABEL=${_label.string}',
        _label,
      ));
    }
    return Ok(addr);
  }

  @override
  String toString() => 'REF($_label)';
}

/// [Words] is Block of [Word]
final class Words {
  final Label? _label;
  final List<Word> words;
  final Map<Label, Word> _references = {};

  Words(this._label, this.words) {
    for (final word in words) {
      for (final label in word.labels) {
        _references[label] = word;
      }
    }
  }

  (Label, Word)? get label {
    final label = _label;
    if (label == null) return null;
    return (label, words.firstWhere((word) => word.labels.contains(_label)));
  }

  Result<List<Real>, List<CompileError>> reals(Resolve resolve, Address start) {
    final errors = <CompileError>[];
    final reals = <Real>[];

    for (final word in words) {
      final result = word.real((label) {
        final word = _references[label];
        if (word == null) {
          return resolve(label);
        }
        return words.indexOf(word) + start;
      });

      if (result.isErr) errors.add(result.err);
      if (result.isOk) reals.add(result.ok);
    }

    if (errors.isNotEmpty) return Err(errors);
    return Ok(reals);
  }

  @override
  String toString() {
    final strs = [
      if (_label != null) 'LABEL($_label)',
      if (_references.isNotEmpty)
        'REFS(${_references.entries.map((entry) => '${entry.key}=${entry.value}').join(',')})',
      'WORDS(${words.join(',')})',
    ];
    return '(${strs.join(',')})';
  }
}
