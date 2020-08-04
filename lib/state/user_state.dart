import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class UserState {
  final String uid;
  final String email;
  final String username;
  final String nickname;
  final String phoneNumber;
  final String platform;

  UserState({
    @required this.uid,
    @required this.email,
    @required this.username,
    @required this.nickname,
    @required this.phoneNumber,
    @required this.platform,
  });

  UserState copyWith({
    @required uid,
    @required email,
    @required username,
    @required nickname,
    @required phoneNumber,
    @required platform,
  }) {
    return UserState(
      uid: uid,
      email: email,
      username: username,
      nickname: nickname,
      phoneNumber: phoneNumber,
      platform: platform,
    );
  }

  factory UserState.initial() {
    return UserState(
      uid: '',
      email: '',
      username: '',
      nickname: '',
      phoneNumber: '',
      platform: '',
    );
  }
}
