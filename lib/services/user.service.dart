import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'authentication.service.dart';
import 'database.service.dart';
import 'storage.service.dart';

class UserService {
  final AuthenticationService _authService = AuthenticationService();
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  UserService()
      : _firebaseAuth = FirebaseAuth.instance,
        _googleSignIn = GoogleSignIn();

  Future<void> attemptToSetUsernameInCache() async {
    // This should be a function
    final r1 = await _authService.getUser();
    final r2 = await _databaseService.getUserWithUID(r1.uid);
    String username;
    // This
    if (r2 != null) {
      if (r2['username'].isNotEmpty) {
        username = r2['username'];
      } else if (r2['nickname'].isNotEmpty) {
        username = r2['nickname'];
      }
      await _storageService.set('username', 'String', username);
    }
  }
}
