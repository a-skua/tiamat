import 'package:tiamat/tiamat.dart';

void main() {
  final asm = 'MAIN\tSTART\n'
      '\tLAD\tGR1,TEXT1\n'
      '\tLAD\tGR2,12\n'
      '\tSVC\t2\t; write\n'
      '\tLAD\tGR1,TEXT2\n'
      '\tLAD\tGR2,34\n'
      '\tSVC\t2\t; write\n'
      '\tLAD\tGR1,IBUF\n'
      '\tLAD\tGR2,10\n'
      '\tSVC\t1\t; read\n'
      '\tLAD\tGR1,IBUF\n'
      '\tLAD\tGR2,10\n'
      '\tSVC\t2\t; write\n'
      '\tRET\n'
      'TEXT1\tDC\t\'hello_world!\'\n'
      'TEXT2\tDC\t\'comet2_emulator_and_casl2_compiler\'\n'
      'IBUF\tDS\t10\n'
      '\tEND\n';
  print('casl2:\n$asm');

  final cc = Casl2();
  final bin = cc.compile(asm);
  print('compiled:\n$bin\n');

  final r = Resource();
  for (var i = 0; i < bin.length; i++) {
    r.memory.setWord(i, bin[i]);
  }

  final c = Comet2();
  c.exec(r);
  print('\nresult:');
  for (var i = 0; i < 8; i++) {
    print('GR$i: ${r.getGR(i)}');
  }
}
