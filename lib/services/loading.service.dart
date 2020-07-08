import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';

class LoadingService {
  final StreamController controller = StreamController<Map>();

  Future<void> add({
    @required bool isOpen,
    bool isSigningOut,
    String title = '',
    String text = '',
    bool showIcon = true,
    String size = 'medium',
    bool showSuccessIcon = false,
  }) async {
    final Map data = {
      'isOpen': isOpen,
      'isSigningOut': false,
      'title': title,
      'text': text,
      'showIcon': showIcon,
      'size': size,
      'showSuccessIcon': showSuccessIcon,
    };

    controller.add(data);
  }
}
