import 'package:flutter/services.dart';
import 'package:ssh/ssh.dart';
import '../__private_config__.dart';
import '../constants.dart';
import '../store.dart';
import '../actions/raspberry_pi_actions.dart';

class RPiService {
  final client = SSHClient(
    host: '192.168.43.52',
    port: 22,
    username: 'pi',
    passwordOrKey: Config.password,
  );

  SSHClient getClient() => client;

  Future<String> connect() async {
    print('RPiService.connect()');
    return client.connect();
  }

  Future<void> disconnect() async {
    await exitTheScript();
    client.disconnect();
  }

  Future<String> exitTheScript() async {
    String response;

    try {
      await client.execute(
        'cd ${Constants.PI_SCRIPT_DIRECTORY}; pkill -f script.py',
      );
      response = Constants.SCRIPT_EXITED;
    } catch (error) {
      if (error.toString().contains(
            'PlatformException(execute_failure, session is down, null',
          )) {
        response = Constants.ERROR_SCRIPT_SESSION_IS_DOWN;
      } else {
        response = error.toString();
      }
    }

    return response;
  }

  Future<void> reboot() async {
    await client.execute(
      'cd ${Constants.PI_SCRIPT_DIRECTORY}; sudo reboot',
    );
  }

  Future<String> startScript({
    int twilightDuration,
    int minutesSinceSunrise,
  }) async {
    print('RPiService startScript()');
    return await client.execute(
      'cd ${Constants.PI_SCRIPT_DIRECTORY} && python3 script.py --twilightDuration $twilightDuration --minutesSinceSunrise $minutesSinceSunrise',
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
