import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import './reducers/app_reducer.dart';
import './services/authentication.service.dart';
import './services/user.service.dart';
import './services/storage.service.dart';
import 'App.dart';
import 'state/position_state.dart';
import './state/app_state.dart';

import 'store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final StorageService _storageService = StorageService();

  SharedPreferences.getInstance().then((prefs) async {
    var phoneVerificationInProgress = prefs.get('phoneVerificationInProgress');
    var forceResendingToken = prefs.get('forceResendingToken');

    if (phoneVerificationInProgress != null && forceResendingToken != null) {
      /**
     * Probalby just call verifyPhoneNumber again. The idea is if there's a
     * an error verifying the phone number, display the enterPhoneNumber screen
     * again, and display a message 
     * "An error ocurred verifying your phone number."
     * "Try again, or exit to the home screen?"
     * 
     * Or just display the message "An error occurred verifying your phone Number"
     * And a new button [Return Home]
     */
    }

    _storageService.removeAll();

    // But for now just navigate to the home page
    runApp(
      App('/', store),
    );
  }).catchError((error) {
    print(
        'An error occurred in main.dart in SharedPreferences.getInstance $error');
    runApp(App('/', store));
  });
}
