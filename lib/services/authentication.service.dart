import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_keto/services/database.service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'storage.service.dart';
import '../constants.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final StorageService _storageService;
  final DatabaseService _databaseService;
  final StreamController phoneAuthenticationController =
      StreamController<Map>.broadcast();

  AuthenticationService({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn(),
        _storageService = StorageService(),
        _databaseService = DatabaseService();

  Future<AuthCredential> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential authCredential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return authCredential;
  }

  Future<dynamic> signInWithCredential(AuthCredential authCredential) async {
    dynamic response;
    try {
      response = await _firebaseAuth.signInWithCredential(authCredential);
    } catch (error) {
      response = error.toString();
    }
    return response;
  }

  Future<dynamic> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    var response;

    try {
      response = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.toString().trim(),
        password: password.toString().trim(),
      );
    } catch (e) {
      print('An error occurred calling signInWithEmailAndPassword $e');
      if (e.toString().contains('ERROR_INVALID_EMAIL')) {
        response = Constants.ERROR_INVALID_EMAIL;
      } else if (e.toString().contains('ERROR_WRONG_PASSWORD')) {
        response = Constants.ERROR_WRONG_PASSWORD;
      } else if (e.toString().contains('ERROR_USER_NOT_FOUND')) {
        response = Constants.ERROR_USER_NOT_FOUND;
      } else if (e.toString().contains('ERROR_USER_DISABLED')) {
        response = Constants.ERROR_USER_DISABLED;
      } else if (e.toString().contains('ERROR_TOO_MANY_REQUESTS')) {
        response = Constants.ERROR_TOO_MANY_SIGNIN_REQUESTS;
      } else if (e.toString().contains('ERROR_OPERATION_NOT_ALLOWED')) {
        response = Constants.ERROR_OPERATION_NOT_ALLOWED;
      } else {
        response = e.toString();
      }
    }

    return response;
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
    print(error.message);

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
