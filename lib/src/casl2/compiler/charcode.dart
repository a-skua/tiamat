import './word.dart' show Real;

typedef Rune = int;

/// JIS X 0201 0x21-0x7E
const latin = ''
    ' !"#\$%&\'()*+,-./'
    '0123456789:;<=>?'
    '@ABCDEFGHIJKLMNO'
    'PQRSTUVWXYZ[¥]^_'
    '`abcdefghijklmno'
    'pqrstuvwxyz{|}~';

final _latin =
    List.generate(latin.runes.length, (i) => 0x20 + i, growable: false);

final _latinRuneAsReal = Map.fromIterables(latin.runes, _latin);
final _latinRealAsRune = Map.fromIterables(_latin, latin.runes);

/// JIS X 0201 0xA1-0xDF
const kana = ''
    '。「」、・ヲァィゥェォャュョッ'
    'ーアイウエオカキクケコサシスセソ'
    'タチツテトナニヌネノハヒフヘホマ'
    'ミムメモヤユヨラリルレロワン゛゜';

final _kana =
    List.generate(kana.runes.length, (i) => 0xa1 + i, growable: false);

final _kanaRuneAsReal = Map.fromIterables(kana.runes, _kana);
final _kanaRealAsRune = Map.fromIterables(_kana, kana.runes);

final Map<int, int> _runeAsReal = Map.from(_latinRuneAsReal)
  ..addAll(_kanaRuneAsReal);
final Map<int, int> _realAsRune = Map.from(_latinRealAsRune)
  ..addAll(_kanaRealAsRune);

@deprecated
int? runeAsCode(Rune rune) => rune.asReal;

@deprecated
int? codeAsRune(Real word) => word.asRune;

extension RuneAsReal on Rune {
  Real? get asReal => _runeAsReal[this];
}

extension RealAsRune on Real {
  Rune? get asRune => _realAsRune[this];
}
