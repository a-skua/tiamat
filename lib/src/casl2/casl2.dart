import 'core/tokenizer.dart' as tokenizer;
import 'core/symbolizer.dart' as symbolizer;
import 'parser.dart' as parser;
import 'core/token.dart';
import 'core/symbol.dart';

typedef Tokenizer = List<Token> Function(String);
typedef Symbolizer = List<Symbol> Function(List<Token>);
typedef Parser = List<int> Function(List<Symbol>);

class Casl2 {
  List<int> compile(final String s) =>
      this.parse(this.symbolize(this.tokenize(s)));

  Tokenizer tokenize = tokenizer.tokenize;
  Symbolizer symbolize = symbolizer.symbolize;
  Parser parse = parser.parse;
}
