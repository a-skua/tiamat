import 'package:tiamat/typedef.dart';
import './lexer.dart';
import './parser.dart';
import './compiler.dart';
import './word.dart';

export './lexer.dart';
export './parser.dart';
export './compiler.dart';
export './word.dart';

abstract class Casl2Error {
  final String message;
  final int start;
  final int end;
  final int lineStart;
  final int lineNumber;

  const Casl2Error(
    this.message, {
    required this.start,
    required this.end,
    required this.lineStart,
    required this.lineNumber,
  });

  @override
  String toString() => 'L$lineNumber: $message';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Casl2Error &&
        other.start == start &&
        other.end == end &&
        other.lineStart == lineStart &&
        other.lineNumber == lineNumber &&
        other.message == message;
  }
}

/// CASL2 instance.
final class Casl2 {
  final Parser _parser;
  final Compiler _compiler;

  const Casl2(this._parser, this._compiler);

  factory Casl2.fromString(final String src) =>
      Casl2(Parser(Lexer.fromString(src)), Compiler());

  Result<List<Statement>, List<ParseError>> parse() {
    final errs = <ParseError>[];
    final stmts = <Statement>[];

    for (final result in _parser.nextStatement()) {
      if (result.isErr) {
        errs.add(result.err);
        continue;
      }

      final node = result.ok;
      stmts.add(node);
    }

    if (errs.isNotEmpty) {
      return Err(errs);
    }

    return Ok(stmts);
  }

  Result<Module, List<Casl2Error>> build() {
    final result = parse();
    if (result.isErr) return Err(result.err);

    final errs = <CompileError>[];
    final flatWords = <Word>[];
    final blockWords = <Words>[];
    final refs = <Label, Word>{};
    for (final stmt in result.ok) {
      final result = _compiler.compile(stmt).map((block) {
        final label = block.label;
        if (label != null) refs[label.$1] = label.$2;
        blockWords.add(block);
        flatWords.addAll(block.words);
      });
      if (result.isErr) errs.add(result.err);
    }
    if (errs.isNotEmpty) return Err(errs);

    final bin = <Real>[];
    for (final block in blockWords) {
      final result = block.reals((label) {
        final word = refs[label];
        if (word == null) {
          return null;
        }
        return flatWords.indexOf(word);
      }, bin.length).map((reals) {
        bin.addAll(reals);
      });
      if (result.isErr) errs.addAll(result.err);
    }

    if (errs.isNotEmpty) return Err(errs);
    return Ok(Module(
      refs.map((label, word) => MapEntry(label, flatWords.indexOf(word))),
      bin,
    ));
  }
}

/// CASL2 Module
final class Module {
  final Map<Label, Address> labels;
  final List<Real> bin;
  Module(this.labels, this.bin);

  @override
  String toString() {
    final refs = labels.entries.map((e) => '${e.key}=${e.value}');
    final words = bin.map((word) => 'CONST($word)');
    return '(REFS(${refs.join(',')}),WORDS(${words.join(',')})';
  }
}
