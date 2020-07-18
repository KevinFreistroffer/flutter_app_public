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

  SSHClient getClient() => client;

  Future<String> connect() async {
    return client.connect();
  }

  Future<void> disconnect() async {
    await exitTheScript();
    client.disconnect();
  }

  Future<void> exitTheScript() async {
    await client.execute(
      'cd ${Constants.PI_SCRIPT_DIRECTORY}; ls\n; python3 -c\'import python.py; python.exitScript()',
    );
  }

  Future<String> startScript() async {
    var startScriptResponse = await client.execute(
      'cd ${Constants.PI_SCRIPT_DIRECTORY}; ls\n; sudo python3 python.py',
    );

    print('startScriptResponse $startScriptResponse');

    return startScriptResponse;
  }

  Future<void> createWPASupplicantFileWithNetworkDetails(
      String ssid, String psk) async {
    await client.execute(
      'cd /etc; printf "network={\n\tssid=\"$ssid\"\n\tpsk=\"psk\"\n\tpriority=1\n}" wpa_supplicant',
    );
  }
}
