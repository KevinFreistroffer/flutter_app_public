import 'package:flutter/material.dart';

class Styles {
  static const stepEmailAndUsername = {
    'label': TextStyle(fontSize: 25, color: Color.fromRGBO(101, 123, 131, 1)),
  };
  static const stepPasswords = {
    'label': TextStyle(fontSize: 25, color: Color.fromRGBO(101, 123, 131, 1)),
  };
  static const textField = {
    'errorStyle': TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.bold,
      fontSize: 15,
      letterSpacing: 0.2,
    )
  };

  static const Map alertDialog = {
    //'titlePadding': EdgeInsets.fromLTRB(24, 24, 24, 0),
    'titlePadding': EdgeInsets.all(0),
    'buttonPadding': EdgeInsets.fromLTRB(24, 0, 24, 0),
    'contentPadding': EdgeInsets.all(30),
    'actions': {
      'flatButton': {
        'text': {
          'fontSize': 16.0,
          'fontWeight': FontWeight.w900,
        }
      }
    },
  };
}
