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
    print('RaspberryPiService exitTheScript()');

    await client.execute(
      'cd ${Constants.PI_SCRIPT_DIRECTORY}; pkill -f script.py',
    );
  }

  Future<void> reboot() async {
    await client.execute(
      'cd ${Constants.PI_SCRIPT_DIRECTORY}; sudo reboot',
    );
  }

  Future<String> startScript({
    // double latitude,
    // double longitude,
    // dynamic sunrise,
    // dynamic sunset,
    // int differenceInMinutes,
    int twilightDuration,
    int minutesSinceSunrise,
  }) async {
    return await client.execute(
      'cd ${Constants.PI_SCRIPT_DIRECTORY} && python3 script.py --twilightDuration $twilightDuration --minutesSinceSunrise 240',
    );
  }

  Future<void> createWPASupplicantFileWithNetworkDetails(
      String ssid, String psk) async {
    try {
      await client.execute(
        'cd /etc; printf "network={\n\tssid=\"$ssid\"\n\tpsk=\"psk\"\n\tpriority=1\n}" wpa_supplicant',
      );
    } catch (error) {
      print(
          'An error occurred in createWPASupplicantFileWithNetworkDetails $error');
    }
  }
}
