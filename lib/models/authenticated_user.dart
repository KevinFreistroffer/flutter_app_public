import 'package:meta/meta.dart';

class AuthenticatedUser {
  final String uid;
  final String email;
  final String username;
  final String nickname;
  final String phoneNumber;
  final String platform;

  AuthenticatedUser({
    @required this.uid,
    @required this.email,
    @required this.username,
    @required this.phoneNumber,
    @required this.nickname,
    @required this.platform,
  });

  // Map<String, String> toMap() {
  //   return {
  //     'email': email,
  //     'username': username,
  //     'password': password,
  //     'phoneNumber': phoneNumber,
  //     'uid': uid ?? '', // TODO
  //     'nickname': nickname ?? '',
  //     'platform': platform ?? '',
  //   };
  // }
}
