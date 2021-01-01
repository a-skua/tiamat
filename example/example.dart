import 'package:tiamat/tiamat.dart';

void main() {
  final cc = Casl2();
  final asm = 'MAIN\tSTART\n'
      '\tLAD\tGR0,10\n'
      '\tLAD\tGR1,1\n'
      '\tCPA\tGR0,GR1\n'
      '\tJPL\tPLS\n'
      '\tSUBA\tGR0,GR1\n'
      '\tJUMP\tEND\n'
      'PLS\tADDA\tGR0,GR1\n'
      'END\tLAD\tGR2,100\n'
      '\tPUSH\t400\n'
      '\tCALL\tSUB\n'
      '\tLAD\tGR3,300\n'
      '\tSLL\tGR1,8\n'
      '\tRET\n'
      'SUB\tPOP\tGR7\n'
      '\tPOP\tGR4\n'
      '\tPUSH\t0,GR7\n'
      '\tRET\n'
      '\tEND';
  print('casl2:\n$asm');

  final bin = cc.compile(asm);
  print('');
  print('compiled:\n$bin');

  final r = Resource();
  for (var i = 0; i < bin.length; i++) {
    r.memory.setWord(i, bin[i]);
  }

  final c = Comet2();
  c.exec(r);
  print('');
  print('result:');
  for (var i = 0; i < 8; i++) {
    print('GR$i: ${r.getGR(i)}');
  }
}
