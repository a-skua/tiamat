typedef Input = String Function();
typedef Output = void Function(String);

/// Interface.
class Device {
  Input input = () => 'hello, world';

  Output output = (final String s) => print(s);
}
