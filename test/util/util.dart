import 'dart:math';

int getX(final int r, {final int base = 1}) {
  const length = 8;
  final rand = Random();
  final x = rand.nextInt(length - base) + base;
  if (r != x) {
    return x;
  }
  return x == (length - 1) ? base : x + 1;
}
