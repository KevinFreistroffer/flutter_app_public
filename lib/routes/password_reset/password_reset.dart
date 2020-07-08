import 'package:flutter/material.dart';
import 'package:flutter_keto/error_dialog.dart';
import 'package:flutter_keto/services/authentication.service.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import '../../services/authentication.service.dart';
import '../../services/loading.service.dart';
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
  final LoadingService _loadingService = LoadingService();
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
    _loadingService.add(
      isOpen: true,
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

    return StreamBuilder(
      initialData: {'isOpen': false, 'isSigningIn': false},
      stream: _loadingService.controller.stream,
      builder: (BuildContext context, snapshot) {
        Widget _widget;
        if (snapshot.hasData && snapshot.data['isOpen'] == true) {
          _widget = LoadingScreen(
            title: snapshot.data['title'] ?? null,
            text: snapshot.data['text'] ?? null,
            size: snapshot.data['size'],
            showIcon: snapshot.data['showIcon'] ?? null,
            showSuccessIcon: snapshot.data['showSuccessIcon'] ?? null,
          );
        } else {
          _widget = Scaffold(
            appBar: snapshot.data['isOpen']
                ? null
                : AppBar(
                    centerTitle: true,
                    title: Text(
                      'Password Reset',
                      style: TextStyle(color: theme.onPrimary),
                    ),
                    backgroundColor: theme.primary,
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
                          SizedBox(height: 7.5),
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
                          SizedBox(height: 37),
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
                          SizedBox(height: 18.5),
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
      },
    );
  }
}
