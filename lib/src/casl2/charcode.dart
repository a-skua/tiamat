import './word.dart';

/// JIS X 0201 0x20-0x7E
const latin = ''
    ' !"#\$%&\'()*+,-./'
    '0123456789:;<=>?'
    '@ABCDEFGHIJKLMNO'
    'PQRSTUVWXYZ[¥]^_'
    '`abcdefghijklmno'
    'pqrstuvwxyz{|}~';

/// JIS X 0201 0xA1-0xDF
const kana = '｡｢｣､･ｦｧｨｩｪｫｬｭｮｯ'
    'ｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿ'
    'ﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏ'
    'ﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝﾞﾟ';

final _runes = latin.runes.toList()..addAll(kana.runes);

/// JIS X 0201 0x21-0x7E, 0xA1-0xDF
final _jis = List.generate(latin.runes.length, (i) => 0x20 + i)
  ..addAll(List.generate(kana.runes.length, (i) => 0xa1 + i));

final _rune2jis = Map.fromIterables(_runes, _jis);
final _jis2rune = Map.fromIterables(_jis, _runes);

/// [Rune] to [Real]
extension RuneToReal on Rune {
  Real get real => _rune2jis[this] ?? 0x20;
}

/// [Real] to [Rune]
extension RealToRune on Real {
  Rune get rune => _jis2rune[this] ?? ' '.runes.first;
}

/// [String] to [List<Real>]
extension StringToReals on String {
  List<Real> get reals => runes.map((rune) => rune.real).toList();
}

/// [List<Real>] to [String]
extension RealsToString on List<Real> {
  String get string =>
      map((real) => real.rune).map((rune) => String.fromCharCode(rune)).join();
}
