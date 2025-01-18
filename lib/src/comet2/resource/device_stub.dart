import 'package:tiamat/typedef.dart';
import '../resource.dart';

final class Default implements Device {
  @override
  Future<Result<String, DeviceError>> read(int len) async {
    throw Exception('Not implemented Device.read');
  }

  @override
  Future<Result<void, DeviceError>> write(String str) async {
    throw Exception('Not implemented Device.write');
  }
}
