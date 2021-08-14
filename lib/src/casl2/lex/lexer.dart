const eof = -1;

class Lexer {
  late final RuneIterator runes;
  Lexer(String str) {
    runes = str.runes.iterator;
  }
}
