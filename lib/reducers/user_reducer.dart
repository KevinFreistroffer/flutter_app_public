import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../actions/user_actions.dart';
import '../state/user_state.dart';

final userReducer = combineReducers<UserState>(
  [
    TypedReducer<UserState, SetUserValuesAction>(_setUserValues),
    TypedReducer<UserState, EmptyUserValuesAction>(_emptyUserValues),
  ],
);

UserState _setUserValues(
  UserState state,
  SetUserValuesAction action,
) {
  return state.copyWith(
    uid: action.uid,
    email: action.email,
    username: action.username,
    nickname: action.nickname,
    phoneNumber: action.phoneNumber,
    platform: action.platform,
  );
}

UserState _emptyUserValues(
  UserState state,
  EmptyUserValuesAction action,
) {
  return state.copyWith(
    uid: '',
    email: '',
    username: '',
    nickname: '',
    phoneNumber: '',
    platform: '',
  );
}
