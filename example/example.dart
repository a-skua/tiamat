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

  final ins = Instruction();
  ins.exec(r);
  print('');
  print('result:');
  print('GR0: ${r.getGR(0)}');
  print('GR1: ${r.getGR(1)}');
  print('GR2: ${r.getGR(2)}');
  print('GR3: ${r.getGR(3)}');
  print('GR4: ${r.getGR(4)}');
  print('GR5: ${r.getGR(5)}');
  print('GR6: ${r.getGR(6)}');
  print('GR7: ${r.getGR(7)}');
}
