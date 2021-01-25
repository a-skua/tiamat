import 'package:tiamat/src/casl2/token/token.dart';
import 'package:tiamat/src/casl2/token/parser.dart';
import 'package:test/test.dart';

void main() {
  group('comment', () {
    test('common', () {
      const s = ';\tDC\t\'foo bar\',#FFFF  ; xx';
      final e = [
        Token(';'.runes.first, Type.comment),
        Token('\t'.runes.first, Type.comment),
        Token('D'.runes.first, Type.comment),
        Token('C'.runes.first, Type.comment),
        Token('\t'.runes.first, Type.comment),
        Token('\''.runes.first, Type.comment),
        Token('f'.runes.first, Type.comment),
        Token('o'.runes.first, Type.comment),
        Token('o'.runes.first, Type.comment),
        Token(' '.runes.first, Type.comment),
        Token('b'.runes.first, Type.comment),
        Token('a'.runes.first, Type.comment),
        Token('r'.runes.first, Type.comment),
        Token('\''.runes.first, Type.comment),
        Token(','.runes.first, Type.comment),
        Token('#'.runes.first, Type.comment),
        Token('F'.runes.first, Type.comment),
        Token('F'.runes.first, Type.comment),
        Token('F'.runes.first, Type.comment),
        Token('F'.runes.first, Type.comment),
        Token(' '.runes.first, Type.comment),
        Token(' '.runes.first, Type.comment),
        Token(';'.runes.first, Type.comment),
        Token(' '.runes.first, Type.comment),
        Token('x'.runes.first, Type.comment),
        Token('x'.runes.first, Type.comment),
      ];

      final a = parse(s);
      expect(a.length, equals(e.length));
      for (var i = 0; i < a.length; i++) {
        expect(a[i].rune, equals(e[i].rune));
        expect(a[i].type, equals(e[i].type));
      }
    });

    test('with space in first', () {
      const s = ' \t; this is comment !\n';
      final e = [
        Token(';'.runes.first, Type.comment),
        Token(' '.runes.first, Type.comment),
        Token('t'.runes.first, Type.comment),
        Token('h'.runes.first, Type.comment),
        Token('i'.runes.first, Type.comment),
        Token('s'.runes.first, Type.comment),
        Token(' '.runes.first, Type.comment),
        Token('i'.runes.first, Type.comment),
        Token('s'.runes.first, Type.comment),
        Token(' '.runes.first, Type.comment),
        Token('c'.runes.first, Type.comment),
        Token('o'.runes.first, Type.comment),
        Token('m'.runes.first, Type.comment),
        Token('m'.runes.first, Type.comment),
        Token('e'.runes.first, Type.comment),
        Token('n'.runes.first, Type.comment),
        Token('t'.runes.first, Type.comment),
        Token(' '.runes.first, Type.comment),
        Token('!'.runes.first, Type.comment),
        Token('\n'.runes.first, Type.endLine),
      ];

      final a = parse(s);
      expect(a.length, equals(e.length));
      for (var i = 0; i < a.length; i++) {
        expect(a[i].rune, equals(e[i].rune));
        expect(a[i].type, equals(e[i].type));
      }
    });
  });

  group('instruction', () {
    group('without operand', () {
      test('only instruction', () {
        const s = ' \tEND  ';
        final e = [
          Token('E'.runes.first, Type.instruction),
          Token('N'.runes.first, Type.instruction),
          Token('D'.runes.first, Type.instruction),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].type, equals(e[i].type));
        }
      });

      test('with endLine', () {
        const s = '\tNOP\n';
        final e = [
          Token('N'.runes.first, Type.instruction),
          Token('O'.runes.first, Type.instruction),
          Token('P'.runes.first, Type.instruction),
          Token('\n'.runes.first, Type.endLine),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].type, equals(e[i].type));
        }
      });

      test('with label', () {
        const s = 'MAIN \tSTART \t\n';
        final e = [
          Token('M'.runes.first, Type.label),
          Token('A'.runes.first, Type.label),
          Token('I'.runes.first, Type.label),
          Token('N'.runes.first, Type.label),
          Token('S'.runes.first, Type.instruction),
          Token('T'.runes.first, Type.instruction),
          Token('A'.runes.first, Type.instruction),
          Token('R'.runes.first, Type.instruction),
          Token('T'.runes.first, Type.instruction),
          Token('\n'.runes.first, Type.endLine),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].type, equals(e[i].type));
        }
      });

      test('with comment', () {
        const s = '  \tRPUSH ;comment!\t\n\n';
        final e = [
          Token('R'.runes.first, Type.instruction),
          Token('P'.runes.first, Type.instruction),
          Token('U'.runes.first, Type.instruction),
          Token('S'.runes.first, Type.instruction),
          Token('H'.runes.first, Type.instruction),
          Token(';'.runes.first, Type.comment),
          Token('c'.runes.first, Type.comment),
          Token('o'.runes.first, Type.comment),
          Token('m'.runes.first, Type.comment),
          Token('m'.runes.first, Type.comment),
          Token('e'.runes.first, Type.comment),
          Token('n'.runes.first, Type.comment),
          Token('t'.runes.first, Type.comment),
          Token('!'.runes.first, Type.comment),
          Token('\t'.runes.first, Type.comment),
          Token('\n'.runes.first, Type.endLine),
          Token('\n'.runes.first, Type.endLine),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].type, equals(e[i].type));
        }
      });

      test('with all', () {
        const s = 'MAIN START ; <- start\n'
            '\tRPUSH\n'
            ' RPOP ;register pop\n'
            '\n'
            '\t NOP\t;\tno operation\n'
            'EXIT RET\n'
            '\tEND';
        final e = [
          Token('M'.runes.first, Type.label),
          Token('A'.runes.first, Type.label),
          Token('I'.runes.first, Type.label),
          Token('N'.runes.first, Type.label),
          Token('S'.runes.first, Type.instruction),
          Token('T'.runes.first, Type.instruction),
          Token('A'.runes.first, Type.instruction),
          Token('R'.runes.first, Type.instruction),
          Token('T'.runes.first, Type.instruction),
          Token(';'.runes.first, Type.comment),
          Token(' '.runes.first, Type.comment),
          Token('<'.runes.first, Type.comment),
          Token('-'.runes.first, Type.comment),
          Token(' '.runes.first, Type.comment),
          Token('s'.runes.first, Type.comment),
          Token('t'.runes.first, Type.comment),
          Token('a'.runes.first, Type.comment),
          Token('r'.runes.first, Type.comment),
          Token('t'.runes.first, Type.comment),
          Token('\n'.runes.first, Type.endLine),
          Token('R'.runes.first, Type.instruction),
          Token('P'.runes.first, Type.instruction),
          Token('U'.runes.first, Type.instruction),
          Token('S'.runes.first, Type.instruction),
          Token('H'.runes.first, Type.instruction),
          Token('\n'.runes.first, Type.endLine),
          Token('R'.runes.first, Type.instruction),
          Token('P'.runes.first, Type.instruction),
          Token('O'.runes.first, Type.instruction),
          Token('P'.runes.first, Type.instruction),
          Token(';'.runes.first, Type.comment),
          Token('r'.runes.first, Type.comment),
          Token('e'.runes.first, Type.comment),
          Token('g'.runes.first, Type.comment),
          Token('i'.runes.first, Type.comment),
          Token('s'.runes.first, Type.comment),
          Token('t'.runes.first, Type.comment),
          Token('e'.runes.first, Type.comment),
          Token('r'.runes.first, Type.comment),
          Token(' '.runes.first, Type.comment),
          Token('p'.runes.first, Type.comment),
          Token('o'.runes.first, Type.comment),
          Token('p'.runes.first, Type.comment),
          Token('\n'.runes.first, Type.endLine),
          Token('\n'.runes.first, Type.endLine),
          Token('N'.runes.first, Type.instruction),
          Token('O'.runes.first, Type.instruction),
          Token('P'.runes.first, Type.instruction),
          Token(';'.runes.first, Type.comment),
          Token('\t'.runes.first, Type.comment),
          Token('n'.runes.first, Type.comment),
          Token('o'.runes.first, Type.comment),
          Token(' '.runes.first, Type.comment),
          Token('o'.runes.first, Type.comment),
          Token('p'.runes.first, Type.comment),
          Token('e'.runes.first, Type.comment),
          Token('r'.runes.first, Type.comment),
          Token('a'.runes.first, Type.comment),
          Token('t'.runes.first, Type.comment),
          Token('i'.runes.first, Type.comment),
          Token('o'.runes.first, Type.comment),
          Token('n'.runes.first, Type.comment),
          Token('\n'.runes.first, Type.endLine),
          Token('E'.runes.first, Type.label),
          Token('X'.runes.first, Type.label),
          Token('I'.runes.first, Type.label),
          Token('T'.runes.first, Type.label),
          Token('R'.runes.first, Type.instruction),
          Token('E'.runes.first, Type.instruction),
          Token('T'.runes.first, Type.instruction),
          Token('\n'.runes.first, Type.endLine),
          Token('E'.runes.first, Type.instruction),
          Token('N'.runes.first, Type.instruction),
          Token('D'.runes.first, Type.instruction),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].type, equals(e[i].type));
        }
      });
    });

    group('with operand', () {
      test('common', () {
        const s = '\tLAD\tGR0,1 \n';
        final e = [
          Token('L'.runes.first, Type.instruction),
          Token('A'.runes.first, Type.instruction),
          Token('D'.runes.first, Type.instruction),
          Token('G'.runes.first, Type.operand),
          Token('R'.runes.first, Type.operand),
          Token('0'.runes.first, Type.operand),
          Token(','.runes.first, Type.operand),
          Token('1'.runes.first, Type.operand),
          Token('\n'.runes.first, Type.endLine),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].type, equals(e[i].type));
        }
      });

      test('with label', () {
        const s = 'MAIN LAD GR7,#FFFF\n';
        final e = [
          Token('M'.runes.first, Type.label),
          Token('A'.runes.first, Type.label),
          Token('I'.runes.first, Type.label),
          Token('N'.runes.first, Type.label),
          Token('L'.runes.first, Type.instruction),
          Token('A'.runes.first, Type.instruction),
          Token('D'.runes.first, Type.instruction),
          Token('G'.runes.first, Type.operand),
          Token('R'.runes.first, Type.operand),
          Token('7'.runes.first, Type.operand),
          Token(','.runes.first, Type.operand),
          Token('#'.runes.first, Type.operand),
          Token('F'.runes.first, Type.operand),
          Token('F'.runes.first, Type.operand),
          Token('F'.runes.first, Type.operand),
          Token('F'.runes.first, Type.operand),
          Token('\n'.runes.first, Type.endLine),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].type, equals(e[i].type));
        }
      });

      test('with comment', () {
        const s = ' LAD GR4,10,GR7\tcomment';
        final e = [
          Token('L'.runes.first, Type.instruction),
          Token('A'.runes.first, Type.instruction),
          Token('D'.runes.first, Type.instruction),
          Token('G'.runes.first, Type.operand),
          Token('R'.runes.first, Type.operand),
          Token('4'.runes.first, Type.operand),
          Token(','.runes.first, Type.operand),
          Token('1'.runes.first, Type.operand),
          Token('0'.runes.first, Type.operand),
          Token(','.runes.first, Type.operand),
          Token('G'.runes.first, Type.operand),
          Token('R'.runes.first, Type.operand),
          Token('7'.runes.first, Type.operand),
          Token('c'.runes.first, Type.comment),
          Token('o'.runes.first, Type.comment),
          Token('m'.runes.first, Type.comment),
          Token('m'.runes.first, Type.comment),
          Token('e'.runes.first, Type.comment),
          Token('n'.runes.first, Type.comment),
          Token('t'.runes.first, Type.comment),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].type, equals(e[i].type));
        }
      });

      test('all', () {
        const s = ' \tDC \t\'\'\'hello, world!\',#FFFF,1,2 comment!\n'
            ';MSG DC \'hello, world\'\n'
            ' \t CALL\tSUB\t; call subroutine\n'
            'SUB\tLAD\tGR0,0\n'
            '\tLAD\tGR1,1 GR1 <- 1\n'
            ' ADDA GR0,GR1';
        final e = [
          Token('D'.runes.first, Type.instruction),
          Token('C'.runes.first, Type.instruction),
          Token('\''.runes.first, Type.operand),
          Token('\''.runes.first, Type.operand),
          Token('\''.runes.first, Type.operand),
          Token('h'.runes.first, Type.operand),
          Token('e'.runes.first, Type.operand),
          Token('l'.runes.first, Type.operand),
          Token('l'.runes.first, Type.operand),
          Token('o'.runes.first, Type.operand),
          Token(','.runes.first, Type.operand),
          Token(' '.runes.first, Type.operand),
          Token('w'.runes.first, Type.operand),
          Token('o'.runes.first, Type.operand),
          Token('r'.runes.first, Type.operand),
          Token('l'.runes.first, Type.operand),
          Token('d'.runes.first, Type.operand),
          Token('!'.runes.first, Type.operand),
          Token('\''.runes.first, Type.operand),
          Token(','.runes.first, Type.operand),
          Token('#'.runes.first, Type.operand),
          Token('F'.runes.first, Type.operand),
          Token('F'.runes.first, Type.operand),
          Token('F'.runes.first, Type.operand),
          Token('F'.runes.first, Type.operand),
          Token(','.runes.first, Type.operand),
          Token('1'.runes.first, Type.operand),
          Token(','.runes.first, Type.operand),
          Token('2'.runes.first, Type.operand),
          Token('c'.runes.first, Type.comment),
          Token('o'.runes.first, Type.comment),
          Token('m'.runes.first, Type.comment),
          Token('m'.runes.first, Type.comment),
          Token('e'.runes.first, Type.comment),
          Token('n'.runes.first, Type.comment),
          Token('t'.runes.first, Type.comment),
          Token('!'.runes.first, Type.comment),
          Token('\n'.runes.first, Type.endLine),
          Token(';'.runes.first, Type.comment),
          Token('M'.runes.first, Type.comment),
          Token('S'.runes.first, Type.comment),
          Token('G'.runes.first, Type.comment),
          Token(' '.runes.first, Type.comment),
          Token('D'.runes.first, Type.comment),
          Token('C'.runes.first, Type.comment),
          Token(' '.runes.first, Type.comment),
          Token('\''.runes.first, Type.comment),
          Token('h'.runes.first, Type.comment),
          Token('e'.runes.first, Type.comment),
          Token('l'.runes.first, Type.comment),
          Token('l'.runes.first, Type.comment),
          Token('o'.runes.first, Type.comment),
          Token(','.runes.first, Type.comment),
          Token(' '.runes.first, Type.comment),
          Token('w'.runes.first, Type.comment),
          Token('o'.runes.first, Type.comment),
          Token('r'.runes.first, Type.comment),
          Token('l'.runes.first, Type.comment),
          Token('d'.runes.first, Type.comment),
          Token('\''.runes.first, Type.comment),
          Token('\n'.runes.first, Type.endLine),
          Token('C'.runes.first, Type.instruction),
          Token('A'.runes.first, Type.instruction),
          Token('L'.runes.first, Type.instruction),
          Token('L'.runes.first, Type.instruction),
          Token('S'.runes.first, Type.operand),
          Token('U'.runes.first, Type.operand),
          Token('B'.runes.first, Type.operand),
          Token(';'.runes.first, Type.comment),
          Token(' '.runes.first, Type.comment),
          Token('c'.runes.first, Type.comment),
          Token('a'.runes.first, Type.comment),
          Token('l'.runes.first, Type.comment),
          Token('l'.runes.first, Type.comment),
          Token(' '.runes.first, Type.comment),
          Token('s'.runes.first, Type.comment),
          Token('u'.runes.first, Type.comment),
          Token('b'.runes.first, Type.comment),
          Token('r'.runes.first, Type.comment),
          Token('o'.runes.first, Type.comment),
          Token('u'.runes.first, Type.comment),
          Token('t'.runes.first, Type.comment),
          Token('i'.runes.first, Type.comment),
          Token('n'.runes.first, Type.comment),
          Token('e'.runes.first, Type.comment),
          Token('\n'.runes.first, Type.endLine),
          Token('S'.runes.first, Type.label),
          Token('U'.runes.first, Type.label),
          Token('B'.runes.first, Type.label),
          Token('L'.runes.first, Type.instruction),
          Token('A'.runes.first, Type.instruction),
          Token('D'.runes.first, Type.instruction),
          Token('G'.runes.first, Type.operand),
          Token('R'.runes.first, Type.operand),
          Token('0'.runes.first, Type.operand),
          Token(','.runes.first, Type.operand),
          Token('0'.runes.first, Type.operand),
          Token('\n'.runes.first, Type.endLine),
          Token('L'.runes.first, Type.instruction),
          Token('A'.runes.first, Type.instruction),
          Token('D'.runes.first, Type.instruction),
          Token('G'.runes.first, Type.operand),
          Token('R'.runes.first, Type.operand),
          Token('1'.runes.first, Type.operand),
          Token(','.runes.first, Type.operand),
          Token('1'.runes.first, Type.operand),
          Token('G'.runes.first, Type.comment),
          Token('R'.runes.first, Type.comment),
          Token('1'.runes.first, Type.comment),
          Token(' '.runes.first, Type.comment),
          Token('<'.runes.first, Type.comment),
          Token('-'.runes.first, Type.comment),
          Token(' '.runes.first, Type.comment),
          Token('1'.runes.first, Type.comment),
          Token('\n'.runes.first, Type.endLine),
          Token('A'.runes.first, Type.instruction),
          Token('D'.runes.first, Type.instruction),
          Token('D'.runes.first, Type.instruction),
          Token('A'.runes.first, Type.instruction),
          Token('G'.runes.first, Type.operand),
          Token('R'.runes.first, Type.operand),
          Token('0'.runes.first, Type.operand),
          Token(','.runes.first, Type.operand),
          Token('G'.runes.first, Type.operand),
          Token('R'.runes.first, Type.operand),
          Token('1'.runes.first, Type.operand),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].type, equals(e[i].type));
        }
      });
    });
  });
}
