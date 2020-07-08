import 'package:flutter/material.dart';

class Styles {
  static const Map alertDialog = {
    'text': TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w100,
    ),
    'titlePadding': EdgeInsets.all(0),
    'buttonPadding': EdgeInsets.fromLTRB(24, 0, 24, 0),
    'contentPadding': EdgeInsets.all(30),
    'actions': {
      'flatButton': {
        'text': {
          'fontSize': 18.5,
        }
      }
    },
  };
}
