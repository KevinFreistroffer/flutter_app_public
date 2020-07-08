import 'package:flutter/material.dart';
import '../constants.dart';

typedef ValueChanged<T> = void Function(String type, String value);

class FormInput extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String type;
  final String placeholder;
  final value;
  final String label;
  final ValueChanged handleOnChange;
  final bool autofocus;
  final error;

  final controller = TextEditingController();

  FormInput({
    Key key,
    @required this.formKey,
    @required this.type,
    @required this.placeholder,
    @required this.value,
    @required this.handleOnChange,
    @required this.error,
    this.label,
    this.autofocus = false,
  }) : super(key: key);

  @override
  void initState() {
    controller.addListener(listenerCallback);
  }

  listenerCallback() {
    handleOnChange(type, controller.text);
  }

  @override
  Widget build(BuildContext context) {
    var _error;

    if (type == 'username') {
      if (error != Constants.ERROR_USERNAME_REQUIRED) {
        _error = null;
      } else {
        _error = error;
      }
    } else if (type == 'password') {
      if (error != Constants.ERROR_PASSWORD_REQUIRED) {
        _error = null;
      } else {
        _error = error;
      }
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            // padding: EdgeInsets.only(top: 5, right: 10, bottom: 5, left: 20),
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                // color: Colors.white,
                // borderRadius: BorderRadius.all(
                //   Radius.circular(1000),
                // ),
                ),
            child: TextFormField(
              controller: controller,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: '',
                labelText: label,
                labelStyle: TextStyle(
                  color: Colors.grey,
                ),
                focusedBorder: InputBorder.none,
                errorText: error,
                errorStyle: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.2,
                  // backgroundColor: Colors.white.withOpacity(0.2),
                ),
                errorMaxLines: 2,
              ),
              autofocus: autofocus,
              // onChanged: (onChangedValue) {
              //   handleOnChange(type, onChangedValue);

              //   // formKey.currentState.validate();
              // },
              // validator: (String validatorValue) {
              //   return validatorValue;
              // },
            ),
          ),
        ),
      ],
    );
  }
}
