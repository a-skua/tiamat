import 'package:tiamat/src/casl2/core/token.dart';
import 'package:tiamat/src/casl2/core/tokenizer.dart';
import 'package:test/test.dart';

class Data {
  final String _str;
  final Type type;

  Data(this._str, this.type) {
    assert(_str.length > 0);
  }

  int get rune => this._str.runes.first;
}

void main() {
  group('comment', () {
    test('normal patterm', () {
      final expected = [
        Data(';', Type.comment),
        Data('\t', Type.comment),
        Data('D', Type.comment),
        Data('C', Type.comment),
        Data('\t', Type.comment),
        Data('\'', Type.comment),
        Data('f', Type.comment),
        Data('o', Type.comment),
        Data('o', Type.comment),
        Data(' ', Type.comment),
        Data('b', Type.comment),
        Data('a', Type.comment),
        Data('r', Type.comment),
        Data('\'', Type.comment),
        Data(',', Type.comment),
        Data('#', Type.comment),
        Data('F', Type.comment),
        Data('F', Type.comment),
        Data('F', Type.comment),
        Data('F', Type.comment),
        Data(' ', Type.comment),
        Data(' ', Type.comment),
        Data(';', Type.comment),
        Data(' ', Type.comment),
        Data('x', Type.comment),
        Data('x', Type.comment),
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
        Data(';', Type.comment),
        Data(' ', Type.comment),
        Data('t', Type.comment),
        Data('h', Type.comment),
        Data('i', Type.comment),
        Data('s', Type.comment),
        Data(' ', Type.comment),
        Data('i', Type.comment),
        Data('s', Type.comment),
        Data(' ', Type.comment),
        Data('c', Type.comment),
        Data('o', Type.comment),
        Data('m', Type.comment),
        Data('m', Type.comment),
        Data('e', Type.comment),
        Data('n', Type.comment),
        Data('t', Type.comment),
        Data(' ', Type.comment),
        Data('!', Type.comment),
        Data('\n', Type.endLine),
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
          Data('E', Type.opecode),
          Data('N', Type.opecode),
          Data('D', Type.opecode),
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
          Data('N', Type.opecode),
          Data('O', Type.opecode),
          Data('P', Type.opecode),
          Data('\n', Type.endLine),
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
          Data('M', Type.label),
          Data('A', Type.label),
          Data('I', Type.label),
          Data('N', Type.label),
          Data('S', Type.opecode),
          Data('T', Type.opecode),
          Data('A', Type.opecode),
          Data('R', Type.opecode),
          Data('T', Type.opecode),
          Data('\n', Type.endLine),
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
          Data('R', Type.opecode),
          Data('P', Type.opecode),
          Data('U', Type.opecode),
          Data('S', Type.opecode),
          Data('H', Type.opecode),
          Data(';', Type.comment),
          Data('c', Type.comment),
          Data('o', Type.comment),
          Data('m', Type.comment),
          Data('m', Type.comment),
          Data('e', Type.comment),
          Data('n', Type.comment),
          Data('t', Type.comment),
          Data('!', Type.comment),
          Data('\t', Type.comment),
          Data('\n', Type.endLine),
          Data('\n', Type.endLine),
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
          Data('M', Type.label),
          Data('A', Type.label),
          Data('I', Type.label),
          Data('N', Type.label),
          Data('S', Type.opecode),
          Data('T', Type.opecode),
          Data('A', Type.opecode),
          Data('R', Type.opecode),
          Data('T', Type.opecode),
          Data(';', Type.comment),
          Data(' ', Type.comment),
          Data('<', Type.comment),
          Data('-', Type.comment),
          Data(' ', Type.comment),
          Data('s', Type.comment),
          Data('t', Type.comment),
          Data('a', Type.comment),
          Data('r', Type.comment),
          Data('t', Type.comment),
          Data('\n', Type.endLine),
          Data('R', Type.opecode),
          Data('P', Type.opecode),
          Data('U', Type.opecode),
          Data('S', Type.opecode),
          Data('H', Type.opecode),
          Data('\n', Type.endLine),
          Data('R', Type.opecode),
          Data('P', Type.opecode),
          Data('O', Type.opecode),
          Data('P', Type.opecode),
          Data(';', Type.comment),
          Data('r', Type.comment),
          Data('e', Type.comment),
          Data('g', Type.comment),
          Data('i', Type.comment),
          Data('s', Type.comment),
          Data('t', Type.comment),
          Data('e', Type.comment),
          Data('r', Type.comment),
          Data(' ', Type.comment),
          Data('p', Type.comment),
          Data('o', Type.comment),
          Data('p', Type.comment),
          Data('\n', Type.endLine),
          Data('\n', Type.endLine),
          Data('N', Type.opecode),
          Data('O', Type.opecode),
          Data('P', Type.opecode),
          Data(';', Type.comment),
          Data('\t', Type.comment),
          Data('n', Type.comment),
          Data('o', Type.comment),
          Data(' ', Type.comment),
          Data('o', Type.comment),
          Data('p', Type.comment),
          Data('e', Type.comment),
          Data('r', Type.comment),
          Data('a', Type.comment),
          Data('t', Type.comment),
          Data('i', Type.comment),
          Data('o', Type.comment),
          Data('n', Type.comment),
          Data('\n', Type.endLine),
          Data('E', Type.label),
          Data('X', Type.label),
          Data('I', Type.label),
          Data('T', Type.label),
          Data('R', Type.opecode),
          Data('E', Type.opecode),
          Data('T', Type.opecode),
          Data('\n', Type.endLine),
          Data('E', Type.opecode),
          Data('N', Type.opecode),
          Data('D', Type.opecode),
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
          Data('L', Type.opecode),
          Data('A', Type.opecode),
          Data('D', Type.opecode),
          Data('G', Type.operand),
          Data('R', Type.operand),
          Data('0', Type.operand),
          Data(',', Type.operand),
          Data('1', Type.operand),
          Data('\n', Type.endLine),
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
          Data('M', Type.label),
          Data('A', Type.label),
          Data('I', Type.label),
          Data('N', Type.label),
          Data('L', Type.opecode),
          Data('A', Type.opecode),
          Data('D', Type.opecode),
          Data('G', Type.operand),
          Data('R', Type.operand),
          Data('7', Type.operand),
          Data(',', Type.operand),
          Data('#', Type.operand),
          Data('F', Type.operand),
          Data('F', Type.operand),
          Data('F', Type.operand),
          Data('F', Type.operand),
          Data('\n', Type.endLine),
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
          Data('L', Type.opecode),
          Data('A', Type.opecode),
          Data('D', Type.opecode),
          Data('G', Type.operand),
          Data('R', Type.operand),
          Data('4', Type.operand),
          Data(',', Type.operand),
          Data('1', Type.operand),
          Data('0', Type.operand),
          Data(',', Type.operand),
          Data('G', Type.operand),
          Data('R', Type.operand),
          Data('7', Type.operand),
          Data('c', Type.comment),
          Data('o', Type.comment),
          Data('m', Type.comment),
          Data('m', Type.comment),
          Data('e', Type.comment),
          Data('n', Type.comment),
          Data('t', Type.comment),
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
          Data('D', Type.opecode),
          Data('C', Type.opecode),
          Data('\'', Type.operand),
          Data('\'', Type.operand),
          Data('\'', Type.operand),
          Data('h', Type.operand),
          Data('e', Type.operand),
          Data('l', Type.operand),
          Data('l', Type.operand),
          Data('o', Type.operand),
          Data(',', Type.operand),
          Data(' ', Type.operand),
          Data('w', Type.operand),
          Data('o', Type.operand),
          Data('r', Type.operand),
          Data('l', Type.operand),
          Data('d', Type.operand),
          Data('!', Type.operand),
          Data('\'', Type.operand),
          Data(',', Type.operand),
          Data('#', Type.operand),
          Data('F', Type.operand),
          Data('F', Type.operand),
          Data('F', Type.operand),
          Data('F', Type.operand),
          Data(',', Type.operand),
          Data('1', Type.operand),
          Data(',', Type.operand),
          Data('2', Type.operand),
          Data('c', Type.comment),
          Data('o', Type.comment),
          Data('m', Type.comment),
          Data('m', Type.comment),
          Data('e', Type.comment),
          Data('n', Type.comment),
          Data('t', Type.comment),
          Data('!', Type.comment),
          Data('\n', Type.endLine),
          Data(';', Type.comment),
          Data('M', Type.comment),
          Data('S', Type.comment),
          Data('G', Type.comment),
          Data(' ', Type.comment),
          Data('D', Type.comment),
          Data('C', Type.comment),
          Data(' ', Type.comment),
          Data('\'', Type.comment),
          Data('h', Type.comment),
          Data('e', Type.comment),
          Data('l', Type.comment),
          Data('l', Type.comment),
          Data('o', Type.comment),
          Data(',', Type.comment),
          Data(' ', Type.comment),
          Data('w', Type.comment),
          Data('o', Type.comment),
          Data('r', Type.comment),
          Data('l', Type.comment),
          Data('d', Type.comment),
          Data('\'', Type.comment),
          Data('\n', Type.endLine),
          Data('C', Type.opecode),
          Data('A', Type.opecode),
          Data('L', Type.opecode),
          Data('L', Type.opecode),
          Data('S', Type.operand),
          Data('U', Type.operand),
          Data('B', Type.operand),
          Data(';', Type.comment),
          Data(' ', Type.comment),
          Data('c', Type.comment),
          Data('a', Type.comment),
          Data('l', Type.comment),
          Data('l', Type.comment),
          Data(' ', Type.comment),
          Data('s', Type.comment),
          Data('u', Type.comment),
          Data('b', Type.comment),
          Data('r', Type.comment),
          Data('o', Type.comment),
          Data('u', Type.comment),
          Data('t', Type.comment),
          Data('i', Type.comment),
          Data('n', Type.comment),
          Data('e', Type.comment),
          Data('\n', Type.endLine),
          Data('S', Type.label),
          Data('U', Type.label),
          Data('B', Type.label),
          Data('L', Type.opecode),
          Data('A', Type.opecode),
          Data('D', Type.opecode),
          Data('G', Type.operand),
          Data('R', Type.operand),
          Data('0', Type.operand),
          Data(',', Type.operand),
          Data('0', Type.operand),
          Data('\n', Type.endLine),
          Data('L', Type.opecode),
          Data('A', Type.opecode),
          Data('D', Type.opecode),
          Data('G', Type.operand),
          Data('R', Type.operand),
          Data('1', Type.operand),
          Data(',', Type.operand),
          Data('1', Type.operand),
          Data('G', Type.comment),
          Data('R', Type.comment),
          Data('1', Type.comment),
          Data(' ', Type.comment),
          Data('<', Type.comment),
          Data('-', Type.comment),
          Data(' ', Type.comment),
          Data('1', Type.comment),
          Data('\n', Type.endLine),
          Data('A', Type.opecode),
          Data('D', Type.opecode),
          Data('D', Type.opecode),
          Data('A', Type.opecode),
          Data('G', Type.operand),
          Data('R', Type.operand),
          Data('0', Type.operand),
          Data(',', Type.operand),
          Data('G', Type.operand),
          Data('R', Type.operand),
          Data('1', Type.operand),
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
