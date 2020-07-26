import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../actions/loading_actions.dart';
import '../models/loading_state.dart';
import '../models/app_state.dart';

final loadingReducer = combineReducers<LoadingState>(
  [
    TypedReducer<LoadingState, SetLoadingValuesAction>(_setLoadingValues),
  ],
);

LoadingState _setLoadingValues(
  LoadingState state,
  SetLoadingValuesAction action,
) {
  return state.copyWith(
    isOpen: action.isOpen,
    showIcon: action.showIcon,
    title: action.title,
    text: action.text,
  );
}
