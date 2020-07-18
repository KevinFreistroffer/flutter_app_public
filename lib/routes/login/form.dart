import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'form_input.dart';
import '../../theme.dart';
import 'login.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Function signInWithCredentials; // add typedefs
  final Function signInWithGoogle; // add typedefs
  final Orientation orientation;
  final List formControls;
  final Size size;
  final bool isSendingRequest;
  final bool formIsValid;

  LoginForm({
    Key key,
    @required this.formKey,
    @required this.formIsValid,
    @required this.signInWithCredentials,
    @required this.signInWithGoogle,
    @required this.orientation,
    @required this.formControls,
    @required this.size,
    @required this.isSendingRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Provider.of<AppTheme>(context);
    final _emailOrUsername = formControls.firstWhere(
      (formControl) => formControl is EmailOrUsername,
    );
    final _password = formControls.firstWhere(
      (formControl) => formControl is Password,
    );

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FormInput(
            value: _emailOrUsername.value,
            autofocus: false,
            type: 'emailOrUsername',
            labelText: 'Email or username',
            placeholder: 'Enter your email or username',
            hintText: '',
            label: "Email or Username",
            handleOnChange: (name, value) {
              _emailOrUsername.setValue(value);
              if (value.isNotEmpty) {
                _emailOrUsername.setError(null);
              }
            },
            error: _emailOrUsername.error,
          ),
          SizedBox(height: 32),
          FormInput(
            value: _password.value,
            autofocus: false,
            type: 'password',
            labelText: 'Password',
            placeholder: 'Enter your password',
            hintText: '',
            label: 'Password',
            handleOnChange: (name, value) {
              _password.setValue(value);
              if (value.isNotEmpty) {
                _password.setError(null);
              }
            },
            error: _password.error,
          ),
        ],
      ),
    );
  }
}
