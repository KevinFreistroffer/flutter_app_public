import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_keto/services/database.service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'storage.service.dart';
import 'loading.service.dart';
import '../constants.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final StorageService _storageService;
  final DatabaseService _databaseService;
  final LoadingService _loadingService;
  final StreamController phoneAuthenticationController =
      StreamController<Map>.broadcast();

  AuthenticationService({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn(),
        _storageService = StorageService(),
        _databaseService = DatabaseService(),
        _loadingService = LoadingService();

  Future<dynamic> beginSignInWithGoogle() async {
    var result;
    GoogleSignInAuthentication googleAuth;
    AuthCredential authCredential;
    GoogleSignInAccount signInResponse = await googleSignIn();

    // Shouldn't have to check because the function is expecting to return this type
    // and the value type is already set to expect to be of GoogleSignInAccount
    if (signInResponse is GoogleSignInAccount) {
      googleAuth = await signInResponse.authentication;
    } else {
      print('signInResponse is NOT GoogleSignInAccount $signInResponse');
      return Constants.ERROR_PLEASE_CHECK_NETWORK;
    }

    try {
      authCredential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      result = authCredential;
    } catch (error) {
      print(
          'An error occurred in authenticationService.signInWithGoogle() $error');
      result = error.toString();
    }

    return result;
  }

  Future<GoogleSignInAccount> googleSignIn() async {
    return _googleSignIn.signIn();
  }

  Future<dynamic> signInWithCredential(AuthCredential authCredential) async {
    dynamic value;
    try {
      value = await _firebaseAuth.signInWithCredential(authCredential);
    } catch (error) {
      var e = error.toString();
      if (e.contains('ERROR_INVALID_CREDENTIAL')) {
        value = Constants.ERROR_INVALID_CREDENTIAL;
      } else if (e.contains('ERROR_USER_DISABLED')) {
        value = Constants.ERROR_USER_DISABLED;
      } else if (e.contains('ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL')) {
        value = Constants.ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL;
      } else if (e.contains('ERROR_INVALID_ACTION_CODE')) {
        value =
            'An error occurred. Please try again.'; // Shouldn't hit this error as not using an email link to sign in.
      }
    }
    return value;
  }

  Future<dynamic> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    var value;

    try {
      value = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.toString().trim(),
        password: password.toString().trim(),
      );
    } catch (e) {
      print('An error occurred calling signInWithEmailAndPassword $e');
      if (e.toString().contains('ERROR_INVALID_EMAIL')) {
        value = Constants.ERROR_INVALID_EMAIL;
      } else if (e.toString().contains('ERROR_WRONG_PASSWORD')) {
        value = Constants.ERROR_WRONG_PASSWORD;
      } else if (e.toString().contains('ERROR_USER_NOT_FOUND')) {
        value = Constants.ERROR_USER_NOT_FOUND;
      } else if (e.toString().contains('ERROR_USER_DISABLED')) {
        value = Constants.ERROR_USER_DISABLED;
      } else if (e.toString().contains('ERROR_TOO_MANY_REQUESTS')) {
        value = Constants.ERROR_TOO_MANY_SIGNIN_REQUESTS;
      } else if (e.toString().contains('ERROR_OPERATION_NOT_ALLOWED')) {
        value = Constants.ERROR_OPERATION_NOT_ALLOWED;
      } else {
        value = e.toString();
      }
    }

    return value;
  }

  AuthCredential getCredential(String verificationID, String smsCode) {
    return PhoneAuthProvider.getCredential(
      verificationId: verificationID,
      smsCode: smsCode,
    );
  }

  Future<void> signOut() async {
    // await _storageService.removeMultiple([
    //   'uid',
    //   'username',
    //   'phoneVerificationInProgress',
    //   'verificationID',
    //   'forceResendToken',
    //   'phoneNumber',
    // ]);

    // _storageService.removeAll();

    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  Future<dynamic> getUser() async {
    return (await _firebaseAuth.currentUser());
  }

  Future<void> sendPasswordResetEmail(String email) async {
    var response;

    try {
      response = _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (error) {
      if (error.toString().contains('ERROR_INVALID_EMAIL')) {
        response = Constants.ERROR_INVALID_EMAIL;
      } else if (error.toString().contains('ERROR_USER_NOT_FOUND')) {
        response = Constants.ERROR_USER_NOT_FOUND;
      } else if (error.toString().contains('ERROR_TOO_MANY_REQUESTS')) {
        response = Constants.ERROR_TOO_MANY_PASSWORD_RESET_REQUESTS;
      } else {
        response = "An error occurred.";
      }
    }

    return response;
  }

  Future<void> verifyPhoneNumber({
    String phoneNumber,
    String verificationID,
    int forceResendingToken,
  }) async {
    await _storageService.set('phoneVerificationInProgress', 'bool', true);

    return _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken ?? null,
      timeout: Duration(seconds: 5),
      verificationCompleted: verificationCompletedCallback,
      verificationFailed: verificationFailedCallback,
      codeSent: codeSentCallback,
      codeAutoRetrievalTimeout: autoRetrievalTimeoutCallback,
    );
  }

  void addToPhoneAuthenticationStream({
    @required bool phoneVerificationInProgress,
    @required bool phoneVerificationSucceeded,
    @required bool phoneVerificationFailed,
    AuthCredential authCredential,
    String error = '',
    String verificationID = '',
    int forceResendingToken,
  }) {
    phoneAuthenticationController.add({
      'phoneVerificationInProgress': phoneVerificationInProgress,
      'phoneVerificationSucceeded': phoneVerificationSucceeded,
      'phoneVerificationFailed': phoneVerificationFailed,
      'authCredential': authCredential,
      'error': error,
      'verificationID': verificationID,
      'forceResendingToken': forceResendingToken,
    });
  }

  Future<void> verificationCompletedCallback(
    AuthCredential authCredential,
  ) async {
    final response = await signInWithCredential(authCredential);

    // Success
    if (response is AuthResult) {
      await _storageService.remove('phoneVerificationInProgress');
      addToPhoneAuthenticationStream(
        phoneVerificationInProgress: true,
        phoneVerificationSucceeded: true,
        phoneVerificationFailed: false,
        authCredential: authCredential,
      );

      await _storageService.remove('phoneVerificationInProgress');
    } else if (response is String) {
      // Error String
      addToPhoneAuthenticationStream(
        phoneVerificationInProgress: false,
        phoneVerificationSucceeded: false,
        phoneVerificationFailed: true,
        error: response,
      );
    }
  }

  void verificationFailedCallback(error) {
    print('authenticationService verificationFailedCallback() error $error');

    if (error is AuthException) {
      addToPhoneAuthenticationStream(
        phoneVerificationInProgress: false,
        phoneVerificationSucceeded: false,
        phoneVerificationFailed: true,
        error: error.message,
      );
    }
  }

  void codeSentCallback(String verificationID, [int forceResendingToken]) {
    final List valuesToCache = [
      {
        'key': 'verificationID',
        'type': 'String',
        'value': 'verificationID',
      },
      {
        'key': 'forceResendingToken',
        'type': 'int',
        'value': 'forceResendingToken'
      },
    ];

    _storageService.setMultiple(valuesToCache).then((value) {
      addToPhoneAuthenticationStream(
        phoneVerificationInProgress: true,
        phoneVerificationSucceeded: false,
        phoneVerificationFailed: false,
        verificationID: verificationID,
        forceResendingToken: forceResendingToken,
      );
    });
  }

  void autoRetrievalTimeoutCallback(String verificationID) {
    _storageService.set('verificationID', 'String', verificationID).then((_) {
      addToPhoneAuthenticationStream(
        phoneVerificationInProgress: true,
        phoneVerificationSucceeded: false,
        phoneVerificationFailed: false,
        verificationID: verificationID,
        forceResendingToken: null,
      );
    });
  }
}
