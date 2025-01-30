import 'package:tiamat/typedef.dart';
import './resource.dart';
import 'dart:io';

final class Default implements Device {
  @override
  Future<Result<String, DeviceError>> read(int len) async {
    return switch (stdin.readLineSync()) {
      String str => Ok(str),
      _ => Err(DeviceError('read error')),
    };
  }

  @override
  Future<Result<void, DeviceError>> write(String str) async {
    stderr.write(str);
    stderr.write('\n');
    return Ok(null);
  }
}
