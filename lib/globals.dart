import 'package:flutter/material.dart';

class Globals {
  GlobalKey _scaffoldKey;
  Globals() {
    _scaffoldKey = GlobalKey();
  }

  GlobalKey get scaffoldKey => _scaffoldKey;
}
