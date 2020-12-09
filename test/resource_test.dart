import 'package:tiamat/src/resource.dart';
import 'package:test/test.dart';

void main() {
  group('GRs', () {
    for (var i = 0; i < GR_SIZE; i++) {
      test('set/get success; GR[$i]', () {
        final r = Resource();
        const val = 8;
        expect(true, r.setGR(i, val));
        expect(val, r.getGR(i));
      });
    }

    for (var i = GR_SIZE; i < GR_SIZE * 2; i++) {
      test('set/get fail; GR[$i]', () {
        final r = Resource();
        const val = 16;
        expect(false, r.setGR(i, val));
        expect(0, r.getGR(i));
      });
    }
  });
}
