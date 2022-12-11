import 'package:tiamat/tiamat.dart';
import 'package:tiamat/casl2.dart';
import 'dart:io';

void main() {
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

  final result = casl2.compile();
  if (result.hasError) {
    for (final error in result.errors) {
      print(error);
    }
    return;
  }

  final comet2 = ImplComet2(
    Device(() {
      stdout.write('YOUR INPUT> ');
      final input = stdin.readLineSync();
      return Future(() => input ?? '');
    }, (str) => print(str)),
    onUpdate: (final r) {
      print(r);
    },
    onChangeStatus: (final s) {
      print('change state: $s');
    },
  )..delay = 10;

  const loadPosition = 100;

  comet2.loadAndRun(loadPosition, result).then((final r) {
    print('exit');
    print(r);
  });
}

void syntaxHighlight(final String asm) {
  const white = 255;
  const yellow = 220;
  const orange = 208;
  const green = 120;
  const red = 196;
  const gray = 240;

  final lexer = ImplLexer(asm.runes);

  var str = '';
  while (!lexer.isLast) {
    final token = lexer.nextToken();
    switch (token.type) {
      case TokenType.label:
        str += '\u001b[38;5;${yellow}m${token.runesAsString}';
        break;
      case TokenType.hex:
      case TokenType.dec:
        str += '\u001b[38;5;92m${token.runesAsString}';
        break;
      case TokenType.ident:
        str += '\u001b[38;5;${yellow}m${token.runesAsString}';
        break;
      case TokenType.gr:
        str += '\u001b[38;5;${orange}m${token.runesAsString}';
        break;
      case TokenType.string:
        str += '\u001b[38;5;${green}m${token.runesAsString}';
        break;
      case TokenType.error:
        str += '\u001b[38;5;${red}m${token.runesAsString}';
        break;
      case TokenType.comment:
        str += '\u001b[38;5;${gray}m${token.runesAsString}';
        break;
      default:
        str += '\u001b[38;5;${white}m${token.runesAsString}';
    }
  }
  print(str);
}
