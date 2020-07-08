import 'package:flutter/material.dart';

class Styles {
  static const Map alertDialog = {
    'text': TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w100,
    ),
    'titlePadding': EdgeInsets.fromLTRB(24, 48, 24, 0),
    'buttonPadding': EdgeInsets.fromLTRB(24, 0, 24, 0),
    'actions': {
      'flatButton': {
        'text': {
          'fontSize': 22.5,
          'fontWeight': FontWeight.w900,
        }
      }
    },
  };
}
