import 'package:flutter/material.dart';

class Styles {
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
