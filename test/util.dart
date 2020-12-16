import 'dart:math';

int getX(final int r, {final int base = 1}) {
  final rand = Random();
  final x = rand.nextInt(8 - base) + base;
  if (r != x) {
    return x;
  }
  return x == 7 ? base : x + 1;
}
