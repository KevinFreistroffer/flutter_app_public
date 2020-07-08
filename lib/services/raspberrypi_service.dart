import 'package:flutter/services.dart';
import 'package:ssh/ssh.dart';
import '../__private_config__.dart';
import '../constants.dart';

class RaspberryPiService {
  final client = SSHClient(
    host: '192.168.43.52',
    port: 22,
    username: 'pi',
    passwordOrKey: Config.password,
  );

  Future<String> connectToClient() async {
    print('RaspberryPi Service connectToClient()');
    String result;
    try {
      result = await client.connect();
      if (result == "session_connected") return result;
      client.disconnect();
    } on PlatformException catch (e) {
      print(
        'An error occurred calling client.connect() \nError: ${e.code}\nError Message: ${e.message}',
      );
    }

    return result;
  }

  disconnectClient() {
    print('raspberryPi disconnectClient()');
    client.disconnect();
  }
}
