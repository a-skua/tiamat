import 'package:tiamat/src/comet2/resource/resource.dart';
import 'package:test/test.dart';

void main() {
  test('ToSigned', _testToSigned);
  test('ToUnsigned', _testToUnsigned);

  group('Resource', () {
    test('zf', _testResourceZF);
    test('sf', _testResourceSF);
    test('of', _testResourceOF);
    test('toString()', _testResourceToString);
  });
}

void _testToSigned() {
  final tests = [
    (0x0000, 0x0000),
    (0x7fff, 0x7fff),
    (0x8000, -0x8000),
    (0xffff, -0x0001),
    (-0x0001, -0x0001),
  ];

  for (final (num, signed) in tests) {
    expect(num.signed, equals(signed));
  }
}

void _testToUnsigned() {
  final tests = [
    (0x0000, 0x0000),
    (0x7fff, 0x7fff),
    (-0x8000, 0x8000),
    (-0x0001, 0xffff),
  ];

  for (final (num, unsigned) in tests) {
    expect(num.unsigned, equals(unsigned));
  }
}

void _testResourceZF() {
  final tests = [
    (0x0006, true, 0x0007),
    (0x0007, false, 0x0006),
  ];

  final resource = Resource();
  for (final (init, flag, expected) in tests) {
    resource.fr = init;
    resource.zf = flag;

    expect(resource.zf, equals(flag));
    expect(resource.fr, equals(expected));
  }
}

void _testResourceSF() {
  final tests = [
    (0x0005, true, 0x0007),
    (0x0007, false, 0x0005),
  ];

  final resource = Resource();
  for (final (init, flag, expected) in tests) {
    resource.fr = init;
    resource.sf = flag;

    expect(resource.sf, equals(flag));
    expect(resource.fr, equals(expected));
  }
}

void _testResourceOF() {
  final tests = [
    (0x0003, true, 0x0007),
    (0x0007, false, 0x0003),
  ];

  final resource = Resource();
  for (final (init, flag, expected) in tests) {
    resource.fr = init;
    resource.of = flag;

    expect(resource.of, equals(flag));
    expect(resource.fr, equals(expected));
  }
}

void _testResourceToString() {
  final tests = [
    (
      Resource(),
      ''
          'GR [0:0000, 1:0000, 2:0000, 3:0000, 4:0000, 5:0000, 6:0000, 7:0000]\n'
          'PR [0000]\n'
          'SP [FFFF]\n'
          'FR [ZF:0, SF:0, OF:0]'
    ),
    (
      Resource()
        ..gr[1] = 0xffff
        ..gr[3] = 0xffff
        ..gr[5] = 0xffff
        ..gr[7] = 0xffff
        ..zf = true,
      ''
          'GR [0:0000, 1:FFFF, 2:0000, 3:FFFF, 4:0000, 5:FFFF, 6:0000, 7:FFFF]\n'
          'PR [0000]\n'
          'SP [FFFF]\n'
          'FR [ZF:1, SF:0, OF:0]'
    ),
  ];

  for (final (resource, expected) in tests) {
    expect('$resource', equals(expected));
  }
}
