import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthentication extends ChangeNotifier {
  // I deleted final from the 6 variables, so that the values can be edited. Is that okay?
  bool _phoneVerificationInProgress;
  bool _phoneVerificationSucceeded;
  bool _phoneVerificationFailed;
  AuthCredential _authCredential;
  dynamic _error;
  String _verificationID;
  String _forceResendingToken;

  UnmodifiableMapView get state => UnmodifiableMapView(
        {
          'phoneVerificationInProgress': _phoneVerificationInProgress ?? '',
          'phoneVerificationSucceeded': _phoneVerificationSucceeded ?? '',
          'phoneVerificationFailed': _phoneVerificationFailed ?? '',
          'authCredential': _authCredential ?? '',
          'error': _error ?? '',
          'verificationID': _verificationID ?? '',
          'forceResendingToken': _forceResendingToken ?? '',
        },
      );

  bool get phoneVerificationInProgress => _phoneVerificationInProgress;
  bool get phoneVerificationSucceeded => _phoneVerificationSucceeded;
  AuthCredential get authCredential => _authCredential;
  String get error => _error;
  String get verificationID => _verificationID;
  String get forceResendingToken => _forceResendingToken;

  void set({
    bool phoneVerificationInProgress,
    bool phoneVerificationSucceeded,
    bool phoneVerificationFailed,
    dynamic authCredential,
    dynamic error,
    String verificationID,
    String forceResendingToken,
  }) {
    _phoneVerificationInProgress =
        phoneVerificationInProgress ?? _phoneVerificationInProgress;
    _phoneVerificationSucceeded =
        phoneVerificationSucceeded ?? _phoneVerificationSucceeded;
    _authCredential = authCredential ?? _authCredential;
    _error = error ?? error;
    _verificationID = verificationID ?? _verificationID;
    _forceResendingToken = forceResendingToken ?? _forceResendingToken;

    notifyListeners();
  }

  void emptyAllValues() {
    _phoneVerificationInProgress = false;
    _phoneVerificationSucceeded = false;
    _authCredential = null;
    _error = null;
    _verificationID = '';
    _forceResendingToken = '';
  }
}
