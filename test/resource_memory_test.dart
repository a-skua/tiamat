import 'dart:math';

import 'package:tiamat/src/resource.dart';
import 'package:test/test.dart';

void main() {
  final rand = Random();

  test('set/get boundary min', () {
    final m = Memory();
    final v = rand.nextInt(1 << 16);

    expect(m.setWord(0, v), equals(true));
    expect(m.getWord(0), equals(v));
  });

  test('set/get boundary max', () {
    final m = Memory();
    final v = rand.nextInt(1 << 16);

    expect(m.setWord(memorySize - 1, v), equals(true));
    expect(m.getWord(memorySize - 1), equals(v));
  });

  test('set/get over boundary of min', () {
    final m = Memory();
    final v = rand.nextInt(1 << 16);

    expect(m.setWord(-1, v), equals(false));
    expect(m.getWord(-1), equals(0));
  });

  test('set/get over boundary of max', () {
    final m = Memory();
    final v = rand.nextInt(1 << 16);

    expect(m.setWord(memorySize, v), equals(false));
    expect(m.getWord(memorySize), equals(0));
  });

  test('set/get all', () {
    final m = Memory();
    final data = List.generate(m.size, (_) => rand.nextInt(wordSize));

    // set all
    for (var i = 0; i < m.size; i++) {
      m.setWord(i, data[i]);
    }

    // get all
    for (var i = 0; i < m.size; i++) {
      expect(m.getWord(i), equals(data[i]));
    }
  });
}
