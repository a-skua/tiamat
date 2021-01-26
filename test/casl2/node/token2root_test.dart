import 'package:tiamat/src/casl2/token/parser.dart';
import 'package:tiamat/src/casl2/node/token2root.dart';
import 'package:test/test.dart';

class Data {
  final String comment;
  final String label;
  final String instruction;
  final String operand;

  Data(this.label, this.instruction, this.operand, this.comment);
}

void main() {
  test('token to root', () {
    final expected = [
      Data('', '', '', '; this is sample code.'),
      Data('MAIN', 'START', '', '; start program'),
      Data('', '', '', '; for var i = 0; i < 10; i++'),
      Data('', 'LAD', 'GR1,0', 'var i = 0'),
      Data('', 'LAD', 'GR0,10', ''),
      Data('LOOP', 'CPL', 'GR1,GR0', ''),
      Data('', 'JZE', 'EXIT', ''),
      Data('', 'LAD', 'GR1,1,GR1', ''),
      Data('', 'JUMP', 'LOOP', ''),
      Data('EXIT', 'OUT', 'MSG,255', '; hello, world!'),
      Data('', 'RET', '', ''),
      Data('MSG', 'DC', '\'hello, world!\',#FFFF', ''),
      Data('', 'END', '', ''),
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

    final actual = token2root(parse(testdata));
    expect(actual.length, equals(expected.length));
    for (var i = 0; i < actual.length; i++) {
      expect(actual[i].comment, equals(expected[i].comment));
      expect(actual[i].label, equals(expected[i].label));
      expect(actual[i].instruction, equals(expected[i].instruction));
      expect(actual[i].operand, equals(expected[i].operand));
    }
  });
}
