import 'package:flutter/material.dart';

class Styles {
  static const Map title = {
    'fontSize': 50.0,
    'margin': {
      'left': 0.0,
      'top': 0.0,
      'right': 0.0,
      'bottom': 50.0,
    },
  };

  static const Map navLinks = {
    'fontSize': 30.0,
  };

  static const signOutLink = {'fontSize': 20.0};

  static const Map formInput = {
    'container': {
      'margin': EdgeInsets.only(bottom: 20),
    },
    'color': TextStyle(color: Colors.black),
    'decoration': {
      'contentPadding': EdgeInsets.only(
        top: 1,
        right: 12,
        bottom: 2,
        left: 12,
      ),
      'fillColor': Colors.white,
      'labelStyle': TextStyle(
        color: Colors.grey,
      ),
      'errorStyle': TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
        fontSize: 15,
        letterSpacing: 0.2,
        // backgroundColor: Colors.white.withOpacity(0.2),
      ),
    }
  };

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
