import 'package:flutter/material.dart';

class SetUserValuesAction {
  final String uid;
  final String email;
  final String username;
  final String nickname;
  final String phoneNumber;
  final String platform;

  SetUserValuesAction({
    this.uid,
    this.email,
    this.username,
    this.nickname,
    this.phoneNumber,
    this.platform,
  });
}

class EmptyUserValuesAction {
  final String uid;
  final String email;
  final String username;
  final String nickname;
  final String phoneNumber;
  final String platform;

  EmptyUserValuesAction({
    @required this.uid,
    @required this.email,
    @required this.username,
    @required this.nickname,
    @required this.phoneNumber,
    @required this.platform,
  });
}
