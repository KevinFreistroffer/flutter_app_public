import 'dart:core';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../models/new_user.dart';

class DatabaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<dynamic> findUserWithEmail(String email) async {
    final snapshot = await Firestore.instance
        .collection('users')
        .where('email', isEqualTo: email.trim())
        .snapshots()
        .firstWhere((snapshot) => snapshot == snapshot);

    return snapshot.documents.length > 0 ? snapshot.documents[0] : null;
  }

  Future<dynamic> getUserWithUsername(String username) async {
    final snapshot = await Firestore.instance
        .collection('users')
        .where('username', isEqualTo: username.trim())
        .snapshots()
        .firstWhere((snapshot) => snapshot == snapshot);

    return snapshot.documents.length > 0 ? snapshot.documents[0] : null;
  }

  Future<dynamic> getUserWithUID(String uid) async {
    final snapshot = await Firestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid.trim())
        .snapshots()
        .firstWhere((snapshot) => snapshot == snapshot);

    return snapshot.documents.length > 0 ? snapshot.documents[0] : null;
  }

  // Firebase default createUser
  Future<dynamic> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    var response;
    try {
      response = _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (e.toString().contains('ERROR_INVALID_EMAIL')) {
        response = Constants.ERROR_INVALID_EMAIL;
      } else if (e.toString().contains('ERROR_EMAIL_ALREADY_IN_USE')) {
        response = Constants.ERROR_ACCOUNT_EXISTS_WITH_EMAIL_ADDRESS;
      } else if (e.toString().contains('ERROR_NETWORK_REQUEST_FAILED')) {
        response = Constants.ERROR_NETWORK_REQUEST_FAILED;
      } else {
        response = Constants.ERROR_PLEASE_TRY_AGAIN;
      }
    }
    return response;
  }

  Future<DocumentReference> createUserWithAdditionalProperties(NewUser user) {
    var response;

    try {
      response = Firestore.instance.collection('users').add({
        'email': user.email,
        'username': user.username,
        'phoneNumber': user.phoneNumber,
        'uid': user.uid,
        'nickname': user.nickname,
        'platform': user.platform,
      });
    } catch (error) {
      response = error.toString();
    }

    return response;
  }

  Future<void> updateUser(String uid, Map data) async {
    dynamic response;

    try {
      response = Firestore.instance.document('users/$uid').updateData(data);
    } catch (error) {
      response = error.toString();
    }

    return response;
  }
}
