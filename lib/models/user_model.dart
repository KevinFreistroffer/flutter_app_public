import 'dart:collection';

import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  // I deleted final from the 6 variables, so that the values can be edited. Is that okay?
  String _uid;
  String _email;
  String _username;
  String _nickname;
  String _phoneNumber;
  String _platform;

  UnmodifiableMapView get user => UnmodifiableMapView(
        {
          'uid': _uid ?? '',
          'email': _email ?? '',
          'username': _username ?? '',
          'nickname': _nickname ?? '',
          'phoneNumber': _phoneNumber ?? '',
          'platform': _platform ?? '',
        },
      );

  String get uid => _uid;
  String get email => _email;
  String get username => _username;
  String get nickname => _nickname;
  String get phoneNumber => _phoneNumber;
  String get platform => _platform;

  void set({
    String uid,
    String email,
    String username,
    String nickname,
    String phoneNumber,
    String platform,
  }) {
    _uid = uid ?? _uid;
    _email = email ?? _email;
    _username = username ?? _username;
    _nickname = nickname ?? _nickname;
    _phoneNumber = phoneNumber ?? _phoneNumber;
    _platform = platform ?? _platform;

    notifyListeners();
  }

  void emptyAllValues() {
    _uid = '';
    _email = '';
    _username = '';
    _nickname = '';
    _phoneNumber = '';
    _platform = '';
  }
}
