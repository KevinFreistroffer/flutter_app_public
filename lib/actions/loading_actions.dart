import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../constants.dart';

class SetLoadingValuesAction {
  final bool isOpen;
  final bool showIcon;
  final String title;
  final String text;

  SetLoadingValuesAction({
    @required this.isOpen,
    @required this.showIcon,
    @required this.title,
    @required this.text,
  });
}
