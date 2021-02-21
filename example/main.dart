import 'package:tiamat/tiamat.dart';

class DeviceCLI extends Device {
  final input = () {
    final list = [
      'hello, world',
      'こんにちは，世界',
      'hello, 世界',
      'foo bar',
      'tofu on fire 📛',
      'exit',
    ];
    var i = 0;

    return () {
      final str = list[i % list.length];
      i += 1;
      return str;
    };
  }();
}

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

  final casl2 = Casl2();

  final code = <int>[];
  try {
    code.addAll(casl2.compile(asm));
    print('compiled:\n$code\n');
  } catch (e) {
    print(e);
    return;
  }

  final comet2 = Comet2()..device = DeviceCLI();
  comet2.load(code);

  comet2.exec();
  print('\nresult:');
  for (var i = 0; i < 8; i++) {
    final gr = comet2.resource.generalRegisters;
    print('GR$i:${gr[i].value}');
  }
}
