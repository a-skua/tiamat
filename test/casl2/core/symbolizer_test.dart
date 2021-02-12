import 'package:tiamat/src/casl2/core/tokenizer.dart';
import 'package:tiamat/src/casl2/core/symbolizer.dart';
import 'package:test/test.dart';

class Data {
  final List<int> comment;
  final List<int> label;
  final List<int> opecode;
  final List<int> operand;

  Data(this.label, this.opecode, this.operand, this.comment);

  factory Data.fromString(
    final String label,
    final String opecode,
    final String operand,
    final String comment,
  ) {
    return Data(
      label.runes.toList(),
      opecode.runes.toList(),
      operand.runes.toList(),
      comment.runes.toList(),
    );
  }
}

void main() {
  test('symbolize', () {
    final expected = [
      Data.fromString('', '', '', '; this is sample code.'),
      Data.fromString('MAIN', 'START', '', '; start program'),
      Data.fromString('', '', '', '; for var i = 0; i < 10; i++'),
      Data.fromString('', 'LAD', 'GR1,0', 'var i = 0'),
      Data.fromString('', 'LAD', 'GR0,10', ''),
      Data.fromString('', '', '', ''),
      Data.fromString('LOOP', 'CPL', 'GR1,GR0', ''),
      Data.fromString('', 'JZE', 'EXIT', ''),
      Data.fromString('', 'LAD', 'GR1,1,GR1', ''),
      Data.fromString('', 'JUMP', 'LOOP', ''),
      Data.fromString('EXIT', 'OUT', 'MSG,255', '; hello, world!'),
      Data.fromString('', 'RET', '', ''),
      Data.fromString('MSG', 'DC', '\'hello, world!\',#FFFF', ''),
      Data.fromString('', 'END', '', ''),
    ];
    const testdata = '; this is sample code.\n'
        'MAIN\tSTART\t; start program\n'
        '; for var i = 0; i < 10; i++\n'
        '\tLAD\tGR1,0\tvar i = 0\n'
        '\tLAD\tGR0,10\n'
        '\n'
        'LOOP\tCPL\tGR1,GR0\n'
        '\tJZE\tEXIT\n'
        '\tLAD\tGR1,1,GR1\n'
        '\tJUMP\tLOOP\n'
        'EXIT\tOUT\tMSG,255\t; hello, world!\n'
        '\tRET\n'
        'MSG\tDC\t\'hello, world!\',#FFFF\n'
        '\tEND';

    final actual = symbolize(tokenize(testdata));
    expect(actual.length, equals(expected.length));
    for (var i = 0; i < actual.length; i++) {
      expect(actual[i].comment, equals(expected[i].comment));
      expect(actual[i].label, equals(expected[i].label));
      expect(actual[i].opecode, equals(expected[i].opecode));
      expect(actual[i].operand, equals(expected[i].operand));
    }
  });
}
