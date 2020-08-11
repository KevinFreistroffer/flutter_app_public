import 'package:flutter/material.dart';
import 'package:flutter_keto/actions/loading_actions.dart';
import 'package:flutter_keto/error_dialog.dart';
import 'package:flutter_keto/services/authentication.service.dart';
import 'package:flutter_keto/state/app_state.dart';
import 'package:flutter_keto/store.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../../services/authentication.service.dart';
import '../../theme.dart';
import '../../constants.dart';
import '../../widgets/loading_screen/LoadingScreen.dart';
import '../../widgets/submit_button.dart';
import '../../wait.dart';

class PasswordReset extends StatefulWidget {
  PasswordReset({Key key}) : super(key: key);

  @override
  _PasswordResetState createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  final AuthenticationService _authService = AuthenticationService();
  String _email = '';
  bool _submitting = false;
  Map<String, dynamic> _errors = {'email': null};

  void _handlesFormInputsChangeValue(String value) {
    setState(() {
      _email = value.trim();
      _errors['email'] = value.isNotEmpty ? null : _errors['email'];
    });
  }

  _validateForm() {
    if (_email.isEmpty) {
      setState(() => _errors['email'] = Constants.ERROR_EMAIL_REQUIRED);
    } else if (!EmailValidator.validate(_email)) {
      setState(() => _errors['email'] = Constants.ERROR_INVALID_EMAIL);
    } else {
      setState(() => _errors['email'] = null);
    }
  }

  Future<void> _handleFormSubmission() async {
    bool errorOccurred = false;
    setState(() => _submitting = true);
    _validateForm();

    if (_errors['email'] == null) {
      try {
        await _authService.sendPasswordResetEmail(_email);
      } catch (error) {
        errorOccurred = true;
        if (error.toString().contains('ERROR_USER_NOT_FOUND')) {
          ErrorDialog.displayErrorDialog(
              context, Constants.ERROR_USER_NOT_FOUND_WITH_EMAIL);
        }
      }

      if (!errorOccurred) {
        _displaySuccessDialog();
      }
    }
    setState(() => _submitting = false);
  }

  Future<void> _handleSuccessConfirmation() async {
    store.dispatch(
      SetLoadingValuesAction(
        isOpen: true,
        showIcon: store.state.loadingState.showIcon,
        title: store.state.loadingState.title,
        text: store.state.loadingState.text,
      ),
    );
    await wait(s: 2);
    Navigator.pushReplacementNamed(
      context,
      '/login',
    );
  }

  dynamic _displaySuccessDialog() {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          final AppTheme theme = Provider.of<AppTheme>(context);

          return AlertDialog(
            title: Container(
                height: 100,
                color: Color.fromRGBO(33, 150, 243, 1),
                child: null),
            titlePadding: EdgeInsets.all(0),
            content: Text('Email sent. Please check your email!',
                style: TextStyle(fontSize: 20)),
            actions: <Widget>[
              GestureDetector(
                onTap: () async {
                  await _handleSuccessConfirmation();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OKAY',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.onBackground.withOpacity(0.75),
                  ),
                ),
              ),
            ],
            actionsPadding: EdgeInsets.all(20),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppTheme theme = Provider.of<AppTheme>(context);

    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          Widget _widget;
          if (state.loadingState.isOpen) {
            _widget = LoadingScreen(
              title: state.loadingState.title ?? null,
              text: state.loadingState.text ?? null,
              showIcon: state.loadingState.showIcon ?? null,
            );
          } else {
            _widget = Scaffold(
              appBar: state.loadingState.isOpen
                  ? null
                  : AppBar(
                      elevation: 2.0,
                      centerTitle: true,
                      title: Text(
                        'Password Reset',
                        style: TextStyle(color: theme.onPrimary),
                      ),
                      backgroundColor: theme.primary,
                      automaticallyImplyLeading: true,
                      iconTheme: IconThemeData(
                        color: Colors.black,
                      ),
                    ),
              body: Container(
                padding: EdgeInsets.fromLTRB(
                  size.width * .1,
                  size.width * .125,
                  size.width * .1,
                  size.width * .125,
                ),
                color: theme.background,
                height: size.height,
                child: Center(
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              child: Text(
                                  'Enter the email of the account\'s password you want to reset.',
                                  style: TextStyle(
                                    fontSize: 25,
                                  )),
                            ),
                            SizedBox(height: 8),
                            new Theme(
                              data: theme.themeData,
                              child: TextFormField(
                                style: TextStyle(
                                  color: theme.onBackground,
                                ),
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  hintText: 'example@example.com',
                                  errorText: _errors['email'],
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black.withOpacity(0.5),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) =>
                                    _handlesFormInputsChangeValue(value),
                              ),
                            ),
                            SizedBox(height: 32),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: SubmitButton(
                                    text: 'NEXT',
                                    isSubmitting: _submitting,
                                    formIsValid:
                                        _errors['email'] == null ? true : false,
                                    handleOnSubmit: _handleFormSubmission,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                    child: Text('Cancel'),
                                    onTap: () => Navigator.of(context).pop()),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          }

          return _widget;
        });
  }
}
