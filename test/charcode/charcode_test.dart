import 'package:tiamat/src/casl2/compiler/charcode.dart';
import 'package:test/test.dart';

void main() {
  test('charcode latin', testCharcode(0x20, 0x7e, latin));
  test('charcode kana', testCharcode(0xa1, 0xdf, kana));
}

dynamic Function() testCharcode(int firstCode, int lastCode, String str) {
  return () {
    var count = firstCode;

    for (final rune in str.runes) {
      final code = runeAsCode(rune);
      expect(code, equals(count));
      expect(codeAsRune(code as int), equals(rune));

      count += 1;
    }

    expect(count, equals(lastCode + 1));
  };
}
