import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
class LoadingState {
  final bool isOpen;
  final bool showIcon;
  final String title;
  final String text;

  LoadingState({
    @required this.isOpen,
    @required this.showIcon,
    @required this.title,
    @required this.text,
  });

  LoadingState copyWith({
    @required isOpen,
    @required showIcon,
    @required title,
    @required text,
  }) {
    return LoadingState(
      isOpen: isOpen,
      showIcon: showIcon,
      title: title,
      text: text,
    );
  }

  @override
  toString() {
    var str = '';

    str += 'SetLoadingAction \n';
    str += '{ isOpen: $isOpen, \n';
    str += 'title: $title, \n';
    str += 'text: $text, \n';
    str += 'showIcon: $showIcon, \n';
    str += ' }';

    return str;
  }

  factory LoadingState.initial() {
    return LoadingState(
      isOpen: false,
      showIcon: true,
      title: '',
      text: '',
    );
  }
}
