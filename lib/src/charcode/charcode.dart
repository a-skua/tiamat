/// JIS X 0201 0x21-0x7E
const latin = '!"#\$%&\'()*+,-./'
    '0123456789:;<=>?'
    '@ABCDEFGHIJKLMNO'
    'PQRSTUVWXYZ[¥]^_'
    '`abcdefghijklmno'
    'pqrstuvwxyz{|}~';

final _latinCode =
    List.generate(latin.runes.length, (i) => 0x21 + i, growable: false);

final _latinRuneAsCode = Map.fromIterables(latin.runes, _latinCode);
final _latinCodeAsRune = Map.fromIterables(_latinCode, latin.runes);

/// JIS X 0201 0xA1-0xDF
const kana = '。「」、・ヲァィゥェォャュョッ'
    'ーアイウエオカキクケコサシスセソ'
    'タチツテトナニヌネノハヒフヘホマ'
    'ミムメモヤユヨラリルレロワン゛゜';

final _kanaCode =
    List.generate(kana.runes.length, (i) => 0xa1 + i, growable: false);

final _kanaRuneAsCode = Map.fromIterables(kana.runes, _kanaCode);
final _kanaCodeAsRune = Map.fromIterables(_kanaCode, kana.runes);

final Map<int, int> _runeAsCode = Map.from(_latinRuneAsCode)
  ..addAll(_kanaRuneAsCode);
final Map<int, int> _codeAsRune = Map.from(_latinCodeAsRune)
  ..addAll(_kanaCodeAsRune);

int? runeAsCode(int rune) => _runeAsCode[rune];
int? codeAsRune(int code) => _codeAsRune[code];
