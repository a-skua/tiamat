import 'dart:math';

class Entity {
  final int value;
  final int data;
  const Entity(this.value, [this.data = 0]);
}

class Flag {
  final bool overflow;
  final bool sign;
  final bool zero;
  const Flag({
    this.overflow = false,
    this.sign = false,
    this.zero = false,
  });
}

class TestData {
  final Entity _r;
  final Entity _x;
  final Entity adr;
  final int pr;
  final int fr;

  TestData(
    this._r,
    this._x, {
    this.adr = const Entity(0),
    this.pr = 0,
    this.fr = 0,
  });

  Entity get r => _r;
  Entity get x => _x;
  Entity get r1 => _r;
  Entity get r2 => _x;
}

int getX(final int r) {
  const length = 8;
  final rand = Random();
  final x = rand.nextInt(length);
  if (r != x) {
    return x;
  }
  return x == (length - 1) ? 0 : x + 1;
}

int getR2(final int r1) => getX(r1);
