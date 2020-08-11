import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
class StorageState {
  final bool isOpen;
  final bool showIcon;
  final String title;
  final String text;

  StorageState({
    @required this.isOpen,
    @required this.showIcon,
    @required this.title,
    @required this.text,
  });

  StorageState copyWith({
    @required isOpen,
    @required showIcon,
    @required title,
    @required text,
  }) {
    return StorageState(
      isOpen: isOpen,
      showIcon: showIcon,
      title: title,
      text: text,
    );
  }

  factory StorageState.initial() {
    return StorageState(
      isOpen: false,
      showIcon: true,
      title: '',
      text: '',
    );
  }
}
