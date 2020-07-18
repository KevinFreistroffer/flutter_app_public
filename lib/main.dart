import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import './services/authentication.service.dart';
import './services/user.service.dart';
import './services/storage.service.dart';
import 'App.dart';
import './constants.dart';
import './state/user_model.dart';
import './state/coordinates_model.dart';
import './state/times_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AuthenticationService _authService = AuthenticationService();
  final StorageService _storageService = StorageService();
  final UserService _userService = UserService();

  // to test each restart
  _authService.signOut();
  _storageService.removeAll();

  final _prefs = SharedPreferences.getInstance().then((prefs) async {
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
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => UserModel(),
          ),
          ChangeNotifierProvider(
            create: (context) => CoordinatesModel(),
          ),
          ChangeNotifierProvider(
            create: (context) => TimesModel(),
          ),
        ],
        child: App('/'),
      ),
    );
  }).catchError((error) {
    print(
        'An error occurred in main.dart in SharedPreferences.getInstance $error');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => UserModel(),
          ),
          ChangeNotifierProvider(
            create: (context) => CoordinatesModel(),
          ),
          ChangeNotifierProvider(
            create: (context) => TimesModel(),
          ),
        ],
        child: App('/'),
      ),
    );
  });
}
