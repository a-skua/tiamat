import 'package:tiamat/src/casl2/node.dart';
import 'package:test/test.dart';

void main() {
  test('parse', () {
    const s = '; this is sample code.\n'
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
    final e = [
      Node(
        comment: '; this is sample code.',
        label: '',
        instruction: '',
        operand: '',
      ),
      Node(
        comment: '; start program',
        label: 'MAIN',
        instruction: 'START',
        operand: '',
      ),
      Node(
        comment: '; for var i = 0; i < 10; i++',
        label: '',
        instruction: '',
        operand: '',
      ),
      Node(
        comment: 'var i = 0',
        label: '',
        instruction: 'LAD',
        operand: 'GR1,0',
      ),
      Node(
        comment: '',
        label: '',
        instruction: 'LAD',
        operand: 'GR0,10',
      ),
      Node(
        comment: '',
        label: 'LOOP',
        instruction: 'CPL',
        operand: 'GR1,GR0',
      ),
      Node(
        comment: '',
        label: '',
        instruction: 'JZE',
        operand: 'EXIT',
      ),
      Node(
        comment: '',
        label: '',
        instruction: 'LAD',
        operand: 'GR1,1,GR1',
      ),
      Node(
        comment: '',
        label: '',
        instruction: 'JUMP',
        operand: 'LOOP',
      ),
      Node(
        comment: '; hello, world!',
        label: 'EXIT',
        instruction: 'OUT',
        operand: 'MSG,255',
      ),
      Node(
        comment: '',
        label: '',
        instruction: 'RET',
        operand: '',
      ),
      Node(
        comment: '',
        label: 'MSG',
        instruction: 'DC',
        operand: '\'hello, world!\',#FFFF',
      ),
      Node(
        comment: '',
        label: '',
        instruction: 'END',
        operand: '',
      ),
    ];

    final a = parse(s);
    expect(a.length, equals(e.length));
    for (var i = 0; i < a.length; i++) {
      expect(a[i].comment, equals(e[i].comment));
      expect(a[i].label, equals(e[i].label));
      expect(a[i].instruction, equals(e[i].instruction));
      expect(a[i].operand, equals(e[i].operand));
    }
  });
}
