import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerService {
  Future<PermissionStatus> requestPermission(Permission permission) async {
    PermissionStatus value;
    // request permission
    switch (permission) {
      case Permission.location:
        value = await Permission.location.request();
        break;
      default:
        value = null;
        break;
    }

    return value;
  }
}
