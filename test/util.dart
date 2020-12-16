int getX(final int r, final int x) {
  if (r == x) {
    final n = x == 7 ? 1 : x + 1;
    return n;
  }
  return x;
}
