import 'package:meta/meta.dart';

class NewUser {
  final String email;
  final String username;
  final String phoneNumber;
  final String uid;
  final String nickname;
  final String platform;

  NewUser({
    @required this.email,
    @required this.username,
    @required this.phoneNumber,
    @required this.uid,
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
