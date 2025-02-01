import 'package:tiamat/tiamat.dart';

Future<void> main() async {
  const asm = '''
; サンプルコード
DO      START
; GR1     AND     GR1,GR1       ; ラベルエラー
LOOP    IN      IBUF,31       ; マクロ
        OUT     OUT,38        ; マクロ
        LAD     GR1,0
        LD      GR0,IBUF,GR1  コメント
        CPL     GR0,EXIT,GR1  ; コメント
        ; LAD     GR0,0
        JNZ     LOOP
        LAD     GR1,1,GR1
        LD      GR0,IBUF,GR1
        CPL     GR0,EXIT,GR1
        JNZ     LOOP
        LAD     GR1,1,GR1
        LD      GR0,IBUF,GR1
        CPL     GR0,EXIT,GR1
        JNZ     LOOP
        LAD     GR1,1,GR1
        LD      GR0,IBUF,GR1
        CPL     GR0,EXIT,GR1
        JNZ     LOOP
        LAD     GR1,1,GR1
        LD      GR0,IBUF,GR1
        CPL     GR0,EXIT,GR1
        JNZ     LOOP
END     OUT     MSG,32        ; マクロ
        RET
EXIT    DC      'exit',-1
OUT     DC      'input:'
IBUF    DS      31
EOF     DC      #FFFF
MSG     DC      'goodbye!',-1
        END

MAIN    START
        CALL DO
        RET
        END
''';
  print('casl2:');
  syntaxHighlight(asm);

  final casl2 = Casl2.fromString(asm);

  final (words, labels) = switch (casl2.build()) {
    Ok<(List<Real>, Map<String, Address>), dynamic> ok => ok.unwrap,
    Err<dynamic, List<Casl2Error>> err => throw Exception(err.unwrap),
  };

  final comet2 = Comet2(words);

  final start = labels['MAIN'] ?? 0;
  await comet2.run(start);
}

void syntaxHighlight(final String asm) {
  const white = 255;
  const yellow = 220;
  const orange = 208;
  const green = 120;
  const red = 196;
  const gray = 240;

  final lexer = Lexer(asm.runes);

  var str = '';
  while (true) {
    final result = lexer.nextToken();
    if (result.isErr) {
      print(result);
      break;
    }
    final token = result.ok;
    if (token == tokenEOF) {
      break;
    }

    switch (token.type) {
      case Type.label:
        str += '\u001b[38;5;${yellow}m${token.string}';
        break;
      case Type.hex:
      case Type.dec:
        str += '\u001b[38;5;92m${token.string}';
        break;
      case Type.ref:
        str += '\u001b[38;5;${yellow}m${token.string}';
        break;
      case Type.gr:
        str += '\u001b[38;5;${orange}m${token.string}';
        break;
      case Type.text:
        str += '\u001b[38;5;${green}m${token.string}';
        break;
      case Type.unexpected:
        str += '\u001b[38;5;${red}m${token.string}';
        break;
      case Type.comment:
        str += '\u001b[38;5;${gray}m${token.string}';
        break;
      default:
        str += '\u001b[38;5;${white}m${token.string}';
    }
  }
  print(str);
}
