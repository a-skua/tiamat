import 'package:tiamat/src/charcode/charcode.dart';
import 'package:test/test.dart';

void main() {
  group('RuneToReal', () {
    test('charcode latin', _testRuneToReal(0x20, 0x7e, latin));
    test('charcode kana', _testRuneToReal(0xa1, 0xdf, kana));
  });
}

void Function() _testRuneToReal(int firstCode, int lastCode, String str) {
  return () {
    var expected = firstCode;

    for (final rune in str.runes) {
      final real = rune.real;
      expect(real, equals(expected));
      expect(expected.rune, equals(rune));
      expected += 1;
    }

    expect(expected, equals(lastCode + 1));
  };
}
