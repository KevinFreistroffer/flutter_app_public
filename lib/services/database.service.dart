import 'dart:core';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';
import '../models/new_user.dart';

class DatabaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Future<dynamic> findUserWithEmail(String email) async {
  //   final snapshot = await Firestore.instance
  //       .collection('users')
  //       .where('email', isEqualTo: email.trim())
  //       .snapshots()
  //       .firstWhere((snapshot) => snapshot == snapshot);

  //   return snapshot.documents.length > 0 ? snapshot.documents[0] : null;
  // }

  Future<dynamic> getUserWithUsername(String username) async {
    dynamic result;

    try {
      final snapshot = await Firestore.instance
          .collection('users')
          .where('username', isEqualTo: username.trim())
          .snapshots()
          .firstWhere((snapshot) => snapshot == snapshot);

      result = snapshot.documents.length > 0 ? snapshot.documents[0] : null;
    } catch (error) {
      print(
          'An error occurred in DatabaseService getUserWithUsername() $error');
      result = error.toString();
      if (error.toString().contains("ERROR_NETWORK_REQUEST_FAILED")) {
        result = Constants.ERROR_NETWORK_REQUEST_FAILED; // Should be a constant
      }
    }

    return result;
  }

  Future<dynamic> getUserWithEmail(String email) async {
    print('getUserWithEmail ${email.trim()}');
    dynamic result;

    try {
      final snapshot = await Firestore.instance
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .snapshots()
          .firstWhere((snapshot) => snapshot == snapshot);

      print('snapshot $snapshot ${snapshot.documents}');

      result = snapshot.documents.length > 0 ? snapshot.documents[0] : null;
    } catch (error) {
      print('An error occurred in DatabaseService getUserWithEmail() $error');
      result = error.toString();
      if (error.toString().contains("ERROR_NETWORK_REQUEST_FAILED")) {
        result = Constants.ERROR_NETWORK_REQUEST_FAILED; // Should be a constant
      }
    }

    print('result $result');

    return result;
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
    dynamic result;
    try {
      result = _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (e.toString().contains('ERROR_INVALID_EMAIL')) {
        result = Constants.ERROR_INVALID_EMAIL;
      } else if (e.toString().contains('ERROR_EMAIL_ALREADY_IN_USE')) {
        result = Constants.ERROR_ACCOUNT_EXISTS_WITH_EMAIL_ADDRESS;
      } else if (e.toString().contains('ERROR_NETWORK_REQUEST_FAILED')) {
        result = Constants.ERROR_NETWORK_REQUEST_FAILED;
      } else {
        result = Constants.ERROR_PLEASE_TRY_AGAIN;
      }
    }
    return result;
  }

  Future<DocumentReference> createUserWithAdditionalProperties(NewUser user) {
    dynamic result;

    try {
      result = Firestore.instance.collection('users').add({
        'email': user.email,
        'username': user.username,
        'phoneNumber': user.phoneNumber,
        'uid': user.uid,
        'nickname': user.nickname,
        'platform': user.platform,
      });
    } catch (error) {
      result = error.toString();
    }

    return result;
  }

  Future<void> updateUser(String uid, Map data) async {
    dynamic result;

    try {
      result = Firestore.instance.document('users/$uid').updateData(data);
    } catch (error) {
      result = error.toString();
    }

    return result;
  }
}
