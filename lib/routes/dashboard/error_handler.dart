import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
// class ErrorHandler extends ErroHandler {}

class HandleError {
  onError(dynamic error) {
    // the complicated part of determing the type of error PlatformError

    // if error is PlatformException

    // if error.contains(ERROR_NO_USER_FOUND)

    // return Constants.ERROR_NO_USER_FOUND

    if (error is DeferredLoadException) {
      print('error is DeferredLoadException $error');
    }
    if (error is FormatException) {
      print('error is DeferredLoadException $error');
    }
    if (error is IntegerDivisionByZeroException) {
      print('error is DeferredLoadException $error');
    }
    if (error is IOException) {
      print('error is DeferredLoadException $error');
    }
    if (error is FormatException) {
      print('error is DeferredLoadException $error');
    }
    if (error is IsolateSpawnException) {
      print('error is DeferredLoadException $error');
    }
    if (error is TimeoutException) {
      print('error is TimeoutException $error');
    }

    if (error is PlatformException) {
      print('error is PlatformException $error');
    }
  }
}
