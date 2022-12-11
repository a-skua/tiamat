typedef Input = Future<String> Function();
typedef Output = void Function(String);

/// Interface.
class Device {
  final Input input;
  final Output output;

  Device(this.input, this.output);
}
