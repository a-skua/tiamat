import 'package:tiamat/typedef.dart';
import '../resource.dart';

final class Default implements Device {
  @override
  Future<Result<String, DeviceError>> read(int len) async {
    return Err(DeviceError('Not implemented Device.read'));
  }

  @override
  Future<Result<void, DeviceError>> write(String str) async {
    return Err(DeviceError('Not implemented Device.write'));
  }
}
