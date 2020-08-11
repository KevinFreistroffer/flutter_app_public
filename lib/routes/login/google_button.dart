import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class GoogleButton extends StatelessWidget {
  final Function handleOnSubmit;
  final bool isSendingRequest;
  // final bool formIsValid;

  const GoogleButton({
    Key key,
    @required this.handleOnSubmit,
    @required this.isSendingRequest,
    // @required this.formIsValid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 240,
          child: SignInButton(
            Buttons.Google,
            text: "Sign in with Google",
            onPressed: () => handleOnSubmit(),
          ),
        ),
      ],
    );
  }
}
