typedef Input = String Function();
typedef Output = void Function(String);

/// Interface.
class Device {
  final Input input = () {
    return 'hello, world';
  };

  final Output output = (final String s) {
    print(s);
  };
}
