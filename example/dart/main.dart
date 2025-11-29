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
    Err err => throw Exception(err.err),
  };

  print('run:');
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
  const purple = 92;

  String colorString(String str, int color) {
    return '\u001b[38;5;${color}m$str';
  }

  final lexer = Lexer(asm.runes);

  var str = '';
  for (final token in lexer.tokenize()) {
    switch (token.type) {
      case Type.label:
      case Type.ref:
        str += colorString(token.string, yellow);
        break;
      case Type.hex:
      case Type.dec:
        str += colorString(token.string, purple);
        break;
      case Type.gr:
        str += colorString(token.string, orange);
        break;
      case Type.text:
        str += colorString(token.string, green);
        break;
      case Type.unexpected:
        str += colorString(token.string, red);
        break;
      case Type.comment:
        str += colorString(token.string, gray);
        break;
      default:
        str += colorString(token.string, white);
    }
  }
  print(str);
}
