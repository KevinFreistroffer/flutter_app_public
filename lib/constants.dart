import 'package:flutter/material.dart';

class Constants {
  static const String APP_NAME = 'FlutterPi';
  static const String ERROR_USERNAME_REQUIRED = 'Username is required.';
  static const String ERROR_PASSWORD_REQUIRED = 'Password is required.';
  static const String ERROR_CONFIRM_YOUR_PASSWORD_REQUIRED =
      'Repeated password is required.';
  static const String ERROR_EMAIL_REQUIRED = 'Email is required.';
  static const String ERROR_EMAIL_OR_USERNAME_REQUIRED =
      'Email or username is required.';
  static const String ERROR_PHONE_NUMBER_REQUIRED = 'Phone number is required.';
  static const String ERROR_SMS_CODE_REQUIRED =
      'Please enter the code sent to your phone.';
  static const String ERROR_NICKNAME_REQUIRED = 'Nickname is required.';
  static const String ERROR_PASSWORD_TOO_SHORT =
      'Password needs to be at least 6 characters.';
  static const String ERROR_SMS_CODE_INVALID_FORMAT =
      'Please enter the 6 digit SMS code.';
  static const String ERROR_INVALID_PHONE_NUMBER =
      'Please enter a 10 digit phone number.';
  static const String ERROR_USERNAME_CANT_BE_AN_EMAIL =
      "Username can't be an email";
  static const String ERROR_INVALID_USERNAME_PASSWORD =
      'Invalid username and/or password.';
  static const String ERROR_WRONG_PASSWORD = 'The password is invalid';
  static const String ERROR_INVALID_EMAIL =
      "This doesn't appear to be a valid email.";
  static const String ERROR_USER_NOT_FOUND =
      'No user exists with that email or username';
  static const String ERROR_USER_NOT_FOUND_WITH_EMAIL =
      'No user exists with that email.';

  static final RegExp emailRegex = new RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

  static const String ERROR_PASSWORDS_DONT_MATCH = "Password's must match.";
  static const String ERROR_USER_DISABLED =
      'That account is disabled. Please contact us for more details.';
  static const String ERROR_TOO_MANY_SIGNIN_REQUESTS =
      'There were too many failed attempts to sign in. Please try again later.';
  static const String ERROR_OPERATION_NOT_ALLOWED =
      'Your account is not enabled. Please contact us.';
  static const String ERROR_INVALID_CREDENTIAL =
      'Credential data is malformed or has expired. Please resend another code.';
  static const String ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL =
      'There already exists an account with the email address. I need to use the fetchSignInMethodsForEmail() and sign in another way if possible.';
  static const String ERROR_ACCOUNT_EXISTS_WITH_EMAIL_ADDRESS =
      'There already exists an account with that email address';
  static const String ERROR_ACCOUNT_EXISTS_WITH_USERNAME =
      'There already exists an account with the username.';
  static const String ERROR_ACCOUNT_EXISTS_WITH_EMAIL_OR_USERNAME =
      'The email address and or username are already registered.';
  static const String ERROR_INVALID_VERIFICATION_CODE = 'Invalid SMS code.';
  static const String ERROR_PLEASE_CHECK_NETWORK =
      'An error occurred. Please make sure your internet connection is available.';
  static const String ERROR_NETWORK_REQUEST_FAILED =
      'A network error occurred. Please check your internet connection is connected, then try again.';
  static const String ERROR_PLEASE_TRY_AGAIN =
      'An error occurred, please try again.';
  static const String ERROR_TOO_MANY_PASSWORD_RESET_REQUESTS =
      'Too many requests. All requests from this device are blocked due to unusual activity. Try again later.';
  static const String COFFEE = "coffee";
  static const String BREAKFAST = "breakfast";
  static const String SIGN_OUT = 'sign out';
  static const double APP_BAR_HEIGHT = 56.0;
  static const String ENTER_YOUR_PHONE_NUMBER = 'enterYourPhoneNumber';
  static const String VERIFY_SMS_CODE = 'verifySMSCode';
  static const String SIGN_IN_WITH_CREDENTIALS = 'signInWithCredentials';
  static const String SIGNIN_STEP_EMAIL_OR_USERNAME_AND_PASSWORD =
      'usernameOrEmailAndPassword';
  static const String SIGNIN_STEP_ENTER_YOUR_PHONE_NUMBER =
      'enterYourPhoneNumber';
  static const String SIGNIN_STEP_VERIFY_SMS_CODE = 'verifySMSCode';
  static const int MAX_USERNAME_DISPLAY_LENGTH = 25;
  static const String EMAIL_OR_USERNAME = 'emailOrUsername';
  static const String GOOGLE = 'Google';
  static const String FIREBASE = 'firebase';
  static const String PHONE = 'phone';
  static const String PROMPTED_TO_CREATE_AN_ACCOUNT = 'prompted';
  static const String SMALL = 'small';
  static const String MEDIUM = 'medium';
  static const String LARGE = 'large';
  static const String HEMISPHERE_NORTHERN = 'Northern';
  static const String HEMISPHERE_SOUTHERN = 'Southern';

  static const List SHARED_PREFS_KEYS = [
    'phoneVerificationInProgress',
    'email',
    'username',
    'phoneNumber',
    'uid',
    'nickname',
    'prompted',
    'signedInPlatform',
    'verificationID',
    'forceResendingToken'
  ];

  static const String SSH_CONNECT = 'Connect';
  static const String SSH_CONNECTED = 'Connected';
  static const String SSH_CONNECTING = 'Connecting';
  static const String SSH_DISCONNECT = 'Disconnect';
  static const String SSH_DISCONNECTED = 'Disconnected';
  static const String LOCATION_NOT_AVAILABLE = 'N/A';
  static const String SSH_CONNECT_SUCCESS = 'session_connected';

  static const String SCRIPT_RUNNING = 'Script Running';
  static const String SCRIPT_NOT_RUNNING = 'Script Not Running';
  static const String SCRIPT_COMPLETED = 'COMPLETED';

  static const String PI_SCRIPT_DIRECTORY =
      '/home/pi/.local/share/applications';

  static const double APP_SPACING_SIZE = 16.0;

  // styles
}
