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
      'EXIT\tDC\t\'exit\',#FFFF\n'
      'OUT\tDC\t\'input:\'\n'
      'IBUF\tDS\t31\n'
      'EOF\tDC\t#FFFF\n'
      'MSG\tDC\t\'goodbye!\',#FFFF\n'
      '\tEND\n';
  print('casl2:\n$asm');

  final cc = Casl2();
  final bin = cc.compile(asm);
  print('compiled: $bin\n');

  final r = Resource();
  for (var i = 0; i < bin.length; i++) {
    r.memory.setWord(i, bin[i]);
  }

  final c = Comet2();
  c.exec(r);
  print('\nresult:');
  for (var i = 0; i < 8; i++) {
    print('GR$i:${r.getGR(i)}');
  }
}
