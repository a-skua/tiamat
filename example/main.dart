import 'package:tiamat/tiamat.dart';

void main() {
  const asm = 'MAIN\tSTART\n'
      'LOOP\tIN\tIBUF,31\n'
      '\tOUT\tOUT,38\n'
      '\tLAD\tGR1,0\n'
      '\tLD\tGR0,IBUF,GR1\n'
      '\tCPL\tGR0,EXIT,GR1\n'
      '\tJNZ\tLOOP\n'
      '\tLAD\tGR1,1,GR1\n'
      '\tLD\tGR0,IBUF,GR1\n'
      '\tCPL\tGR0,EXIT,GR1\n'
      '\tJNZ\tLOOP\n'
      '\tLAD\tGR1,1,GR1\n'
      '\tLD\tGR0,IBUF,GR1\n'
      '\tCPL\tGR0,EXIT,GR1\n'
      '\tJNZ\tLOOP\n'
      '\tLAD\tGR1,1,GR1\n'
      '\tLD\tGR0,IBUF,GR1\n'
      '\tCPL\tGR0,EXIT,GR1\n'
      '\tJNZ\tLOOP\n'
      '\tLAD\tGR1,1,GR1\n'
      '\tLD\tGR0,IBUF,GR1\n'
      '\tCPL\tGR0,EXIT,GR1\n'
      '\tJNZ\tLOOP\n'
      'END\tOUT\tMSG,32\n'
      '\tRET\n'
      'EXIT\tDC\t\'exit\',-1\n'
      'OUT\tDC\t\'input:\'\n'
      'IBUF\tDS\t31\n'
      'EOF\tDC\t#FFFF\n'
      'MSG\tDC\t\'goodbye!\',-1\n'
      '\tEND\n';
  print('casl2:\n$asm');

  final cc = Casl2();
  final bin = cc.compile(asm);
  print('compiled:\n$bin\n');

  final r = Resource();
  r.memory.setAll(0, bin);

  final c = Comet2();
  c.sv.read = () {
    final list = [
      'hello, world',
      'foo bar',
      'exit',
    ];
    var i = 0;
    return () {
      i += 1;
      return list[i % list.length];
    };
  }();
  c.exec(r);
  print('\nresult:');
  for (var i = 0; i < 8; i++) {
    print('GR$i:${r.getGR(i)}');
  }
}
