import 'package:tiamat/src/casl2/token.dart';
import 'package:test/test.dart';

void main() {
  group('comment', () {
    test('common', () {
      const s = ';\tDC\t\'foo bar\',#FFFF  ; xx';
      final e = [
        Token(';'.runes.first, State.comment),
        Token('\t'.runes.first, State.comment),
        Token('D'.runes.first, State.comment),
        Token('C'.runes.first, State.comment),
        Token('\t'.runes.first, State.comment),
        Token('\''.runes.first, State.comment),
        Token('f'.runes.first, State.comment),
        Token('o'.runes.first, State.comment),
        Token('o'.runes.first, State.comment),
        Token(' '.runes.first, State.comment),
        Token('b'.runes.first, State.comment),
        Token('a'.runes.first, State.comment),
        Token('r'.runes.first, State.comment),
        Token('\''.runes.first, State.comment),
        Token(','.runes.first, State.comment),
        Token('#'.runes.first, State.comment),
        Token('F'.runes.first, State.comment),
        Token('F'.runes.first, State.comment),
        Token('F'.runes.first, State.comment),
        Token('F'.runes.first, State.comment),
        Token(' '.runes.first, State.comment),
        Token(' '.runes.first, State.comment),
        Token(';'.runes.first, State.comment),
        Token(' '.runes.first, State.comment),
        Token('x'.runes.first, State.comment),
        Token('x'.runes.first, State.comment),
      ];

      final a = parse(s);
      expect(a.length, equals(e.length));
      for (var i = 0; i < a.length; i++) {
        expect(a[i].rune, equals(e[i].rune));
        expect(a[i].state, equals(e[i].state));
      }
    });

    test('with space in first', () {
      const s = ' \t; this is comment !\n';
      final e = [
        Token(';'.runes.first, State.comment),
        Token(' '.runes.first, State.comment),
        Token('t'.runes.first, State.comment),
        Token('h'.runes.first, State.comment),
        Token('i'.runes.first, State.comment),
        Token('s'.runes.first, State.comment),
        Token(' '.runes.first, State.comment),
        Token('i'.runes.first, State.comment),
        Token('s'.runes.first, State.comment),
        Token(' '.runes.first, State.comment),
        Token('c'.runes.first, State.comment),
        Token('o'.runes.first, State.comment),
        Token('m'.runes.first, State.comment),
        Token('m'.runes.first, State.comment),
        Token('e'.runes.first, State.comment),
        Token('n'.runes.first, State.comment),
        Token('t'.runes.first, State.comment),
        Token(' '.runes.first, State.comment),
        Token('!'.runes.first, State.comment),
        Token('\n'.runes.first, State.newline),
      ];

      final a = parse(s);
      expect(a.length, equals(e.length));
      for (var i = 0; i < a.length; i++) {
        expect(a[i].rune, equals(e[i].rune));
        expect(a[i].state, equals(e[i].state));
      }
    });
  });

  group('instruction', () {
    group('without operand', () {
      test('only instruction', () {
        const s = ' \tEND  ';
        final e = [
          Token('E'.runes.first, State.instruction),
          Token('N'.runes.first, State.instruction),
          Token('D'.runes.first, State.instruction),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].state, equals(e[i].state));
        }
      });

      test('with newline', () {
        const s = '\tNOP\n';
        final e = [
          Token('N'.runes.first, State.instruction),
          Token('O'.runes.first, State.instruction),
          Token('P'.runes.first, State.instruction),
          Token('\n'.runes.first, State.newline),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].state, equals(e[i].state));
        }
      });

      test('with label', () {
        const s = 'MAIN \tSTART \t\n';
        final e = [
          Token('M'.runes.first, State.label),
          Token('A'.runes.first, State.label),
          Token('I'.runes.first, State.label),
          Token('N'.runes.first, State.label),
          Token('S'.runes.first, State.instruction),
          Token('T'.runes.first, State.instruction),
          Token('A'.runes.first, State.instruction),
          Token('R'.runes.first, State.instruction),
          Token('T'.runes.first, State.instruction),
          Token('\n'.runes.first, State.newline),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].state, equals(e[i].state));
        }
      });

      test('with comment', () {
        const s = '  \tRPUSH ;comment!\t\n\n';
        final e = [
          Token('R'.runes.first, State.instruction),
          Token('P'.runes.first, State.instruction),
          Token('U'.runes.first, State.instruction),
          Token('S'.runes.first, State.instruction),
          Token('H'.runes.first, State.instruction),
          Token(';'.runes.first, State.comment),
          Token('c'.runes.first, State.comment),
          Token('o'.runes.first, State.comment),
          Token('m'.runes.first, State.comment),
          Token('m'.runes.first, State.comment),
          Token('e'.runes.first, State.comment),
          Token('n'.runes.first, State.comment),
          Token('t'.runes.first, State.comment),
          Token('!'.runes.first, State.comment),
          Token('\t'.runes.first, State.comment),
          Token('\n'.runes.first, State.newline),
          Token('\n'.runes.first, State.newline),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].state, equals(e[i].state));
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
          Token('M'.runes.first, State.label),
          Token('A'.runes.first, State.label),
          Token('I'.runes.first, State.label),
          Token('N'.runes.first, State.label),
          Token('S'.runes.first, State.instruction),
          Token('T'.runes.first, State.instruction),
          Token('A'.runes.first, State.instruction),
          Token('R'.runes.first, State.instruction),
          Token('T'.runes.first, State.instruction),
          Token(';'.runes.first, State.comment),
          Token(' '.runes.first, State.comment),
          Token('<'.runes.first, State.comment),
          Token('-'.runes.first, State.comment),
          Token(' '.runes.first, State.comment),
          Token('s'.runes.first, State.comment),
          Token('t'.runes.first, State.comment),
          Token('a'.runes.first, State.comment),
          Token('r'.runes.first, State.comment),
          Token('t'.runes.first, State.comment),
          Token('\n'.runes.first, State.newline),
          Token('R'.runes.first, State.instruction),
          Token('P'.runes.first, State.instruction),
          Token('U'.runes.first, State.instruction),
          Token('S'.runes.first, State.instruction),
          Token('H'.runes.first, State.instruction),
          Token('\n'.runes.first, State.newline),
          Token('R'.runes.first, State.instruction),
          Token('P'.runes.first, State.instruction),
          Token('O'.runes.first, State.instruction),
          Token('P'.runes.first, State.instruction),
          Token(';'.runes.first, State.comment),
          Token('r'.runes.first, State.comment),
          Token('e'.runes.first, State.comment),
          Token('g'.runes.first, State.comment),
          Token('i'.runes.first, State.comment),
          Token('s'.runes.first, State.comment),
          Token('t'.runes.first, State.comment),
          Token('e'.runes.first, State.comment),
          Token('r'.runes.first, State.comment),
          Token(' '.runes.first, State.comment),
          Token('p'.runes.first, State.comment),
          Token('o'.runes.first, State.comment),
          Token('p'.runes.first, State.comment),
          Token('\n'.runes.first, State.newline),
          Token('\n'.runes.first, State.newline),
          Token('N'.runes.first, State.instruction),
          Token('O'.runes.first, State.instruction),
          Token('P'.runes.first, State.instruction),
          Token(';'.runes.first, State.comment),
          Token('\t'.runes.first, State.comment),
          Token('n'.runes.first, State.comment),
          Token('o'.runes.first, State.comment),
          Token(' '.runes.first, State.comment),
          Token('o'.runes.first, State.comment),
          Token('p'.runes.first, State.comment),
          Token('e'.runes.first, State.comment),
          Token('r'.runes.first, State.comment),
          Token('a'.runes.first, State.comment),
          Token('t'.runes.first, State.comment),
          Token('i'.runes.first, State.comment),
          Token('o'.runes.first, State.comment),
          Token('n'.runes.first, State.comment),
          Token('\n'.runes.first, State.newline),
          Token('E'.runes.first, State.label),
          Token('X'.runes.first, State.label),
          Token('I'.runes.first, State.label),
          Token('T'.runes.first, State.label),
          Token('R'.runes.first, State.instruction),
          Token('E'.runes.first, State.instruction),
          Token('T'.runes.first, State.instruction),
          Token('\n'.runes.first, State.newline),
          Token('E'.runes.first, State.instruction),
          Token('N'.runes.first, State.instruction),
          Token('D'.runes.first, State.instruction),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].state, equals(e[i].state));
        }
      });
    });

    group('with operand', () {
      test('common', () {
        const s = '\tLAD\tGR0,1 \n';
        final e = [
          Token('L'.runes.first, State.instruction),
          Token('A'.runes.first, State.instruction),
          Token('D'.runes.first, State.instruction),
          Token('G'.runes.first, State.operand),
          Token('R'.runes.first, State.operand),
          Token('0'.runes.first, State.operand),
          Token(','.runes.first, State.operand),
          Token('1'.runes.first, State.operand),
          Token('\n'.runes.first, State.newline),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].state, equals(e[i].state));
        }
      });

      test('with label', () {
        const s = 'MAIN LAD GR7,#FFFF\n';
        final e = [
          Token('M'.runes.first, State.label),
          Token('A'.runes.first, State.label),
          Token('I'.runes.first, State.label),
          Token('N'.runes.first, State.label),
          Token('L'.runes.first, State.instruction),
          Token('A'.runes.first, State.instruction),
          Token('D'.runes.first, State.instruction),
          Token('G'.runes.first, State.operand),
          Token('R'.runes.first, State.operand),
          Token('7'.runes.first, State.operand),
          Token(','.runes.first, State.operand),
          Token('#'.runes.first, State.operand),
          Token('F'.runes.first, State.operand),
          Token('F'.runes.first, State.operand),
          Token('F'.runes.first, State.operand),
          Token('F'.runes.first, State.operand),
          Token('\n'.runes.first, State.newline),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].state, equals(e[i].state));
        }
      });

      test('with comment', () {
        const s = ' LAD GR4,10,GR7\tcomment';
        final e = [
          Token('L'.runes.first, State.instruction),
          Token('A'.runes.first, State.instruction),
          Token('D'.runes.first, State.instruction),
          Token('G'.runes.first, State.operand),
          Token('R'.runes.first, State.operand),
          Token('4'.runes.first, State.operand),
          Token(','.runes.first, State.operand),
          Token('1'.runes.first, State.operand),
          Token('0'.runes.first, State.operand),
          Token(','.runes.first, State.operand),
          Token('G'.runes.first, State.operand),
          Token('R'.runes.first, State.operand),
          Token('7'.runes.first, State.operand),
          Token('c'.runes.first, State.comment),
          Token('o'.runes.first, State.comment),
          Token('m'.runes.first, State.comment),
          Token('m'.runes.first, State.comment),
          Token('e'.runes.first, State.comment),
          Token('n'.runes.first, State.comment),
          Token('t'.runes.first, State.comment),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].state, equals(e[i].state));
        }
      });

      test('all', () {
        const s = ' \tDC \t\'\\\'hello, world!\',#FFFF,1,2 comment!\n'
            ';MSG DC \'hello, world\'\n'
            ' \t CALL\tSUB\t; call subroutine\n'
            'SUB\tLAD\tGR0,0\n'
            '\tLAD\tGR1,1 GR1 <- 1\n'
            ' ADDA GR0,GR1';
        final e = [
          Token('D'.runes.first, State.instruction),
          Token('C'.runes.first, State.instruction),
          Token('\''.runes.first, State.operand),
          Token('\\'.runes.first, State.operand),
          Token('\''.runes.first, State.operand),
          Token('h'.runes.first, State.operand),
          Token('e'.runes.first, State.operand),
          Token('l'.runes.first, State.operand),
          Token('l'.runes.first, State.operand),
          Token('o'.runes.first, State.operand),
          Token(','.runes.first, State.operand),
          Token(' '.runes.first, State.operand),
          Token('w'.runes.first, State.operand),
          Token('o'.runes.first, State.operand),
          Token('r'.runes.first, State.operand),
          Token('l'.runes.first, State.operand),
          Token('d'.runes.first, State.operand),
          Token('!'.runes.first, State.operand),
          Token('\''.runes.first, State.operand),
          Token(','.runes.first, State.operand),
          Token('#'.runes.first, State.operand),
          Token('F'.runes.first, State.operand),
          Token('F'.runes.first, State.operand),
          Token('F'.runes.first, State.operand),
          Token('F'.runes.first, State.operand),
          Token(','.runes.first, State.operand),
          Token('1'.runes.first, State.operand),
          Token(','.runes.first, State.operand),
          Token('2'.runes.first, State.operand),
          Token('c'.runes.first, State.comment),
          Token('o'.runes.first, State.comment),
          Token('m'.runes.first, State.comment),
          Token('m'.runes.first, State.comment),
          Token('e'.runes.first, State.comment),
          Token('n'.runes.first, State.comment),
          Token('t'.runes.first, State.comment),
          Token('!'.runes.first, State.comment),
          Token('\n'.runes.first, State.newline),
          Token(';'.runes.first, State.comment),
          Token('M'.runes.first, State.comment),
          Token('S'.runes.first, State.comment),
          Token('G'.runes.first, State.comment),
          Token(' '.runes.first, State.comment),
          Token('D'.runes.first, State.comment),
          Token('C'.runes.first, State.comment),
          Token(' '.runes.first, State.comment),
          Token('\''.runes.first, State.comment),
          Token('h'.runes.first, State.comment),
          Token('e'.runes.first, State.comment),
          Token('l'.runes.first, State.comment),
          Token('l'.runes.first, State.comment),
          Token('o'.runes.first, State.comment),
          Token(','.runes.first, State.comment),
          Token(' '.runes.first, State.comment),
          Token('w'.runes.first, State.comment),
          Token('o'.runes.first, State.comment),
          Token('r'.runes.first, State.comment),
          Token('l'.runes.first, State.comment),
          Token('d'.runes.first, State.comment),
          Token('\''.runes.first, State.comment),
          Token('\n'.runes.first, State.newline),
          Token('C'.runes.first, State.instruction),
          Token('A'.runes.first, State.instruction),
          Token('L'.runes.first, State.instruction),
          Token('L'.runes.first, State.instruction),
          Token('S'.runes.first, State.operand),
          Token('U'.runes.first, State.operand),
          Token('B'.runes.first, State.operand),
          Token(';'.runes.first, State.comment),
          Token(' '.runes.first, State.comment),
          Token('c'.runes.first, State.comment),
          Token('a'.runes.first, State.comment),
          Token('l'.runes.first, State.comment),
          Token('l'.runes.first, State.comment),
          Token(' '.runes.first, State.comment),
          Token('s'.runes.first, State.comment),
          Token('u'.runes.first, State.comment),
          Token('b'.runes.first, State.comment),
          Token('r'.runes.first, State.comment),
          Token('o'.runes.first, State.comment),
          Token('u'.runes.first, State.comment),
          Token('t'.runes.first, State.comment),
          Token('i'.runes.first, State.comment),
          Token('n'.runes.first, State.comment),
          Token('e'.runes.first, State.comment),
          Token('\n'.runes.first, State.newline),
          Token('S'.runes.first, State.label),
          Token('U'.runes.first, State.label),
          Token('B'.runes.first, State.label),
          Token('L'.runes.first, State.instruction),
          Token('A'.runes.first, State.instruction),
          Token('D'.runes.first, State.instruction),
          Token('G'.runes.first, State.operand),
          Token('R'.runes.first, State.operand),
          Token('0'.runes.first, State.operand),
          Token(','.runes.first, State.operand),
          Token('0'.runes.first, State.operand),
          Token('\n'.runes.first, State.newline),
          Token('L'.runes.first, State.instruction),
          Token('A'.runes.first, State.instruction),
          Token('D'.runes.first, State.instruction),
          Token('G'.runes.first, State.operand),
          Token('R'.runes.first, State.operand),
          Token('1'.runes.first, State.operand),
          Token(','.runes.first, State.operand),
          Token('1'.runes.first, State.operand),
          Token('G'.runes.first, State.comment),
          Token('R'.runes.first, State.comment),
          Token('1'.runes.first, State.comment),
          Token(' '.runes.first, State.comment),
          Token('<'.runes.first, State.comment),
          Token('-'.runes.first, State.comment),
          Token(' '.runes.first, State.comment),
          Token('1'.runes.first, State.comment),
          Token('\n'.runes.first, State.newline),
          Token('A'.runes.first, State.instruction),
          Token('D'.runes.first, State.instruction),
          Token('D'.runes.first, State.instruction),
          Token('A'.runes.first, State.instruction),
          Token('G'.runes.first, State.operand),
          Token('R'.runes.first, State.operand),
          Token('0'.runes.first, State.operand),
          Token(','.runes.first, State.operand),
          Token('G'.runes.first, State.operand),
          Token('R'.runes.first, State.operand),
          Token('1'.runes.first, State.operand),
        ];

        final a = parse(s);
        expect(a.length, equals(e.length));
        for (var i = 0; i < a.length; i++) {
          expect(a[i].rune, equals(e[i].rune));
          expect(a[i].state, equals(e[i].state));
        }
      });
    });
  });
}
