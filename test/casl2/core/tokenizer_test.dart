import 'package:tiamat/src/casl2/core/token.dart';
import 'package:tiamat/src/casl2/core/tokenizer.dart';
import 'package:test/test.dart';

class Data {
  final String _str;
  final TokenType type;

  Data(this._str, this.type) {
    assert(_str.length > 0);
  }

  int get rune => this._str.runes.first;
}

void main() {
  group('comment', () {
    test('normal patterm', () {
      final expected = [
        Data(';', TokenType.comment),
        Data('\t', TokenType.comment),
        Data('D', TokenType.comment),
        Data('C', TokenType.comment),
        Data('\t', TokenType.comment),
        Data('\'', TokenType.comment),
        Data('f', TokenType.comment),
        Data('o', TokenType.comment),
        Data('o', TokenType.comment),
        Data(' ', TokenType.comment),
        Data('b', TokenType.comment),
        Data('a', TokenType.comment),
        Data('r', TokenType.comment),
        Data('\'', TokenType.comment),
        Data(',', TokenType.comment),
        Data('#', TokenType.comment),
        Data('F', TokenType.comment),
        Data('F', TokenType.comment),
        Data('F', TokenType.comment),
        Data('F', TokenType.comment),
        Data(' ', TokenType.comment),
        Data(' ', TokenType.comment),
        Data(';', TokenType.comment),
        Data(' ', TokenType.comment),
        Data('x', TokenType.comment),
        Data('x', TokenType.comment),
      ];
      const testdata = ';\tDC\t\'foo bar\',#FFFF  ; xx';

      final actual = tokenize(testdata);
      expect(actual.length, equals(expected.length));
      for (var i = 0; i < actual.length; i++) {
        expect(actual[i].rune, equals(expected[i].rune));
        expect(actual[i].type, equals(expected[i].type));
      }
    });

    test('with space in first', () {
      final expected = [
        Data(';', TokenType.comment),
        Data(' ', TokenType.comment),
        Data('t', TokenType.comment),
        Data('h', TokenType.comment),
        Data('i', TokenType.comment),
        Data('s', TokenType.comment),
        Data(' ', TokenType.comment),
        Data('i', TokenType.comment),
        Data('s', TokenType.comment),
        Data(' ', TokenType.comment),
        Data('c', TokenType.comment),
        Data('o', TokenType.comment),
        Data('m', TokenType.comment),
        Data('m', TokenType.comment),
        Data('e', TokenType.comment),
        Data('n', TokenType.comment),
        Data('t', TokenType.comment),
        Data(' ', TokenType.comment),
        Data('!', TokenType.comment),
        Data('\n', TokenType.endLine),
      ];
      const testdata = ' \t; this is comment !\n';

      final actual = tokenize(testdata);
      expect(actual.length, equals(expected.length));
      for (var i = 0; i < actual.length; i++) {
        expect(actual[i].rune, equals(expected[i].rune));
        expect(actual[i].type, equals(expected[i].type));
      }
    });
  });

  group('opecode', () {
    group('without operand', () {
      test('only opecode', () {
        final expected = [
          Data('E', TokenType.opecode),
          Data('N', TokenType.opecode),
          Data('D', TokenType.opecode),
        ];
        const testdata = ' \tEND  ';

        final actual = tokenize(testdata);
        expect(actual.length, equals(expected.length));
        for (var i = 0; i < actual.length; i++) {
          expect(actual[i].rune, equals(expected[i].rune));
          expect(actual[i].type, equals(expected[i].type));
        }
      });

      test('with endLine', () {
        final expected = [
          Data('N', TokenType.opecode),
          Data('O', TokenType.opecode),
          Data('P', TokenType.opecode),
          Data('\n', TokenType.endLine),
        ];
        const testdata = '\tNOP \n';

        final actual = tokenize(testdata);
        expect(actual.length, equals(expected.length));
        for (var i = 0; i < actual.length; i++) {
          expect(actual[i].rune, equals(expected[i].rune));
          expect(actual[i].type, equals(expected[i].type));
        }
      });

      test('with label', () {
        final expected = [
          Data('M', TokenType.label),
          Data('A', TokenType.label),
          Data('I', TokenType.label),
          Data('N', TokenType.label),
          Data('S', TokenType.opecode),
          Data('T', TokenType.opecode),
          Data('A', TokenType.opecode),
          Data('R', TokenType.opecode),
          Data('T', TokenType.opecode),
          Data('\n', TokenType.endLine),
        ];
        const testdata = 'MAIN \tSTART \t\n';

        final actual = tokenize(testdata);
        expect(actual.length, equals(expected.length));
        for (var i = 0; i < actual.length; i++) {
          expect(actual[i].rune, equals(expected[i].rune));
          expect(actual[i].type, equals(expected[i].type));
        }
      });

      test('with comment', () {
        final expected = [
          Data('R', TokenType.opecode),
          Data('P', TokenType.opecode),
          Data('U', TokenType.opecode),
          Data('S', TokenType.opecode),
          Data('H', TokenType.opecode),
          Data(';', TokenType.comment),
          Data('c', TokenType.comment),
          Data('o', TokenType.comment),
          Data('m', TokenType.comment),
          Data('m', TokenType.comment),
          Data('e', TokenType.comment),
          Data('n', TokenType.comment),
          Data('t', TokenType.comment),
          Data('!', TokenType.comment),
          Data('\t', TokenType.comment),
          Data('\n', TokenType.endLine),
          Data('\n', TokenType.endLine),
        ];
        const testdata = '  \tRPUSH ;comment!\t\n\n';

        final actual = tokenize(testdata);
        expect(actual.length, equals(expected.length));
        for (var i = 0; i < actual.length; i++) {
          expect(actual[i].rune, equals(expected[i].rune));
          expect(actual[i].type, equals(expected[i].type));
        }
      });

      test('with all', () {
        final expected = [
          Data('M', TokenType.label),
          Data('A', TokenType.label),
          Data('I', TokenType.label),
          Data('N', TokenType.label),
          Data('S', TokenType.opecode),
          Data('T', TokenType.opecode),
          Data('A', TokenType.opecode),
          Data('R', TokenType.opecode),
          Data('T', TokenType.opecode),
          Data(';', TokenType.comment),
          Data(' ', TokenType.comment),
          Data('<', TokenType.comment),
          Data('-', TokenType.comment),
          Data(' ', TokenType.comment),
          Data('s', TokenType.comment),
          Data('t', TokenType.comment),
          Data('a', TokenType.comment),
          Data('r', TokenType.comment),
          Data('t', TokenType.comment),
          Data('\n', TokenType.endLine),
          Data('R', TokenType.opecode),
          Data('P', TokenType.opecode),
          Data('U', TokenType.opecode),
          Data('S', TokenType.opecode),
          Data('H', TokenType.opecode),
          Data('\n', TokenType.endLine),
          Data('R', TokenType.opecode),
          Data('P', TokenType.opecode),
          Data('O', TokenType.opecode),
          Data('P', TokenType.opecode),
          Data(';', TokenType.comment),
          Data('r', TokenType.comment),
          Data('e', TokenType.comment),
          Data('g', TokenType.comment),
          Data('i', TokenType.comment),
          Data('s', TokenType.comment),
          Data('t', TokenType.comment),
          Data('e', TokenType.comment),
          Data('r', TokenType.comment),
          Data(' ', TokenType.comment),
          Data('p', TokenType.comment),
          Data('o', TokenType.comment),
          Data('p', TokenType.comment),
          Data('\n', TokenType.endLine),
          Data('\n', TokenType.endLine),
          Data('N', TokenType.opecode),
          Data('O', TokenType.opecode),
          Data('P', TokenType.opecode),
          Data(';', TokenType.comment),
          Data('\t', TokenType.comment),
          Data('n', TokenType.comment),
          Data('o', TokenType.comment),
          Data(' ', TokenType.comment),
          Data('o', TokenType.comment),
          Data('p', TokenType.comment),
          Data('e', TokenType.comment),
          Data('r', TokenType.comment),
          Data('a', TokenType.comment),
          Data('t', TokenType.comment),
          Data('i', TokenType.comment),
          Data('o', TokenType.comment),
          Data('n', TokenType.comment),
          Data('\n', TokenType.endLine),
          Data('E', TokenType.label),
          Data('X', TokenType.label),
          Data('I', TokenType.label),
          Data('T', TokenType.label),
          Data('R', TokenType.opecode),
          Data('E', TokenType.opecode),
          Data('T', TokenType.opecode),
          Data('\n', TokenType.endLine),
          Data('E', TokenType.opecode),
          Data('N', TokenType.opecode),
          Data('D', TokenType.opecode),
        ];
        const testdata = 'MAIN START ; <- start\n'
            '\tRPUSH\n'
            ' RPOP ;register pop\n'
            '\n'
            '\t NOP\t;\tno operation\n'
            'EXIT RET\n'
            '\tEND';

        final actual = tokenize(testdata);
        expect(actual.length, equals(expected.length));
        for (var i = 0; i < actual.length; i++) {
          expect(actual[i].rune, equals(expected[i].rune));
          expect(actual[i].type, equals(expected[i].type));
        }
      });
    });

    group('with operand', () {
      test('common', () {
        final expected = [
          Data('L', TokenType.opecode),
          Data('A', TokenType.opecode),
          Data('D', TokenType.opecode),
          Data('G', TokenType.operand),
          Data('R', TokenType.operand),
          Data('0', TokenType.operand),
          Data(',', TokenType.operand),
          Data('1', TokenType.operand),
          Data('\n', TokenType.endLine),
        ];
        const testdata = '\tLAD\tGR0,1 \n';

        final actual = tokenize(testdata);
        expect(actual.length, equals(expected.length));
        for (var i = 0; i < actual.length; i++) {
          expect(actual[i].rune, equals(expected[i].rune));
          expect(actual[i].type, equals(expected[i].type));
        }
      });

      test('with label', () {
        final expected = [
          Data('M', TokenType.label),
          Data('A', TokenType.label),
          Data('I', TokenType.label),
          Data('N', TokenType.label),
          Data('L', TokenType.opecode),
          Data('A', TokenType.opecode),
          Data('D', TokenType.opecode),
          Data('G', TokenType.operand),
          Data('R', TokenType.operand),
          Data('7', TokenType.operand),
          Data(',', TokenType.operand),
          Data('#', TokenType.operand),
          Data('F', TokenType.operand),
          Data('F', TokenType.operand),
          Data('F', TokenType.operand),
          Data('F', TokenType.operand),
          Data('\n', TokenType.endLine),
        ];
        const testdata = 'MAIN LAD GR7,#FFFF\n';

        final actual = tokenize(testdata);
        expect(actual.length, equals(expected.length));
        for (var i = 0; i < actual.length; i++) {
          expect(actual[i].rune, equals(expected[i].rune));
          expect(actual[i].type, equals(expected[i].type));
        }
      });

      test('with comment', () {
        final expected = [
          Data('L', TokenType.opecode),
          Data('A', TokenType.opecode),
          Data('D', TokenType.opecode),
          Data('G', TokenType.operand),
          Data('R', TokenType.operand),
          Data('4', TokenType.operand),
          Data(',', TokenType.operand),
          Data('1', TokenType.operand),
          Data('0', TokenType.operand),
          Data(',', TokenType.operand),
          Data('G', TokenType.operand),
          Data('R', TokenType.operand),
          Data('7', TokenType.operand),
          Data('c', TokenType.comment),
          Data('o', TokenType.comment),
          Data('m', TokenType.comment),
          Data('m', TokenType.comment),
          Data('e', TokenType.comment),
          Data('n', TokenType.comment),
          Data('t', TokenType.comment),
        ];
        const testdata = ' LAD GR4,10,GR7\tcomment';

        final actual = tokenize(testdata);
        expect(actual.length, equals(expected.length));
        for (var i = 0; i < actual.length; i++) {
          expect(actual[i].rune, equals(expected[i].rune));
          expect(actual[i].type, equals(expected[i].type));
        }
      });

      test('all', () {
        final expected = [
          Data('D', TokenType.opecode),
          Data('C', TokenType.opecode),
          Data('\'', TokenType.operand),
          Data('\'', TokenType.operand),
          Data('\'', TokenType.operand),
          Data('h', TokenType.operand),
          Data('e', TokenType.operand),
          Data('l', TokenType.operand),
          Data('l', TokenType.operand),
          Data('o', TokenType.operand),
          Data(',', TokenType.operand),
          Data(' ', TokenType.operand),
          Data('w', TokenType.operand),
          Data('o', TokenType.operand),
          Data('r', TokenType.operand),
          Data('l', TokenType.operand),
          Data('d', TokenType.operand),
          Data('!', TokenType.operand),
          Data('\'', TokenType.operand),
          Data(',', TokenType.operand),
          Data('#', TokenType.operand),
          Data('F', TokenType.operand),
          Data('F', TokenType.operand),
          Data('F', TokenType.operand),
          Data('F', TokenType.operand),
          Data(',', TokenType.operand),
          Data('1', TokenType.operand),
          Data(',', TokenType.operand),
          Data('2', TokenType.operand),
          Data('c', TokenType.comment),
          Data('o', TokenType.comment),
          Data('m', TokenType.comment),
          Data('m', TokenType.comment),
          Data('e', TokenType.comment),
          Data('n', TokenType.comment),
          Data('t', TokenType.comment),
          Data('!', TokenType.comment),
          Data('\n', TokenType.endLine),
          Data(';', TokenType.comment),
          Data('M', TokenType.comment),
          Data('S', TokenType.comment),
          Data('G', TokenType.comment),
          Data(' ', TokenType.comment),
          Data('D', TokenType.comment),
          Data('C', TokenType.comment),
          Data(' ', TokenType.comment),
          Data('\'', TokenType.comment),
          Data('h', TokenType.comment),
          Data('e', TokenType.comment),
          Data('l', TokenType.comment),
          Data('l', TokenType.comment),
          Data('o', TokenType.comment),
          Data(',', TokenType.comment),
          Data(' ', TokenType.comment),
          Data('w', TokenType.comment),
          Data('o', TokenType.comment),
          Data('r', TokenType.comment),
          Data('l', TokenType.comment),
          Data('d', TokenType.comment),
          Data('\'', TokenType.comment),
          Data('\n', TokenType.endLine),
          Data('C', TokenType.opecode),
          Data('A', TokenType.opecode),
          Data('L', TokenType.opecode),
          Data('L', TokenType.opecode),
          Data('S', TokenType.operand),
          Data('U', TokenType.operand),
          Data('B', TokenType.operand),
          Data(';', TokenType.comment),
          Data(' ', TokenType.comment),
          Data('c', TokenType.comment),
          Data('a', TokenType.comment),
          Data('l', TokenType.comment),
          Data('l', TokenType.comment),
          Data(' ', TokenType.comment),
          Data('s', TokenType.comment),
          Data('u', TokenType.comment),
          Data('b', TokenType.comment),
          Data('r', TokenType.comment),
          Data('o', TokenType.comment),
          Data('u', TokenType.comment),
          Data('t', TokenType.comment),
          Data('i', TokenType.comment),
          Data('n', TokenType.comment),
          Data('e', TokenType.comment),
          Data('\n', TokenType.endLine),
          Data('S', TokenType.label),
          Data('U', TokenType.label),
          Data('B', TokenType.label),
          Data('L', TokenType.opecode),
          Data('A', TokenType.opecode),
          Data('D', TokenType.opecode),
          Data('G', TokenType.operand),
          Data('R', TokenType.operand),
          Data('0', TokenType.operand),
          Data(',', TokenType.operand),
          Data('0', TokenType.operand),
          Data('\n', TokenType.endLine),
          Data('L', TokenType.opecode),
          Data('A', TokenType.opecode),
          Data('D', TokenType.opecode),
          Data('G', TokenType.operand),
          Data('R', TokenType.operand),
          Data('1', TokenType.operand),
          Data(',', TokenType.operand),
          Data('1', TokenType.operand),
          Data('G', TokenType.comment),
          Data('R', TokenType.comment),
          Data('1', TokenType.comment),
          Data(' ', TokenType.comment),
          Data('<', TokenType.comment),
          Data('-', TokenType.comment),
          Data(' ', TokenType.comment),
          Data('1', TokenType.comment),
          Data('\n', TokenType.endLine),
          Data('A', TokenType.opecode),
          Data('D', TokenType.opecode),
          Data('D', TokenType.opecode),
          Data('A', TokenType.opecode),
          Data('G', TokenType.operand),
          Data('R', TokenType.operand),
          Data('0', TokenType.operand),
          Data(',', TokenType.operand),
          Data('G', TokenType.operand),
          Data('R', TokenType.operand),
          Data('1', TokenType.operand),
        ];
        const testdata = ' \tDC \t\'\'\'hello, world!\',#FFFF,1,2 comment!\n'
            ';MSG DC \'hello, world\'\n'
            ' \t CALL\tSUB\t; call subroutine\n'
            'SUB\tLAD\tGR0,0\n'
            '\tLAD\tGR1,1 GR1 <- 1\n'
            ' ADDA GR0,GR1';

        final actual = tokenize(testdata);
        expect(actual.length, equals(expected.length));
        for (var i = 0; i < actual.length; i++) {
          expect(actual[i].rune, equals(expected[i].rune));
          expect(actual[i].type, equals(expected[i].type));
        }
      });
    });
  });
}
