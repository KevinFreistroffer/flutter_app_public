import 'dart:async';

import 'package:flutter_keto/actions/loading_actions.dart';
import 'package:flutter_keto/actions/user_actions.dart';
import 'package:flutter_keto/widgets/welcome.text.dart';
import 'package:flutter_keto/state/app_state.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../services/authentication.service.dart';
import '../../services/database.service.dart';
import '../../services/storage.service.dart';
import '../../services/user.service.dart';
import 'form.dart';
import '../../constants.dart';
import '../../widgets/loading_screen/LoadingScreen.dart';
import '../../widgets/submit_button.dart';
import '../../theme.dart';
import 'styles.dart';
import '../../error_dialog.dart';
import '../../widgets/form_control.dart';
import 'package:flutter_keto/store.dart';

typedef Callback = void Function(
  dynamic error, {
  AuthCredential authCredential,
  String verificationID,
  int forceResendingToken,
});

class StepEmailOrUsername {}

class StepPasswords {}

class EmailOrUsername extends FormControl {}

class Password extends FormControl {}

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final AuthenticationService _authService = AuthenticationService();
  final StorageService _storageService = StorageService();
  final DatabaseService _databaseService = DatabaseService();
  final UserService _userService = UserService();
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'openid',
    ],
  );

  EmailOrUsername _emailOrUsername;
  Password _password;
  bool _formIsValid = false;
  bool _submitting = false;
  bool _showLoadingScreen = false;
  String _currentStep = Constants.SIGNIN_STEP_EMAIL_OR_USERNAME_AND_PASSWORD;

  LoginState() {
    _emailOrUsername = EmailOrUsername()
      ..setValue('')
      ..setError(null);
    _password = Password()
      ..setValue('')
      ..setError(null);
  }

  Future<void> signInWithGoogle() async {
    final AuthCredential authCredential =
        await _authService.beginSignInWithGoogle();
    final result = await _authService.signInWithCredential(authCredential);

    if (result is AuthResult) {
      // success
      final FirebaseUser user = await _authService.getUser();

      await _storageService.set('uid', 'String', user.uid);
      await _userService.attemptToSetUsernameInCache();
      await _storageService.setIfDoesNotExist(
        Constants.PROMPTED_TO_CREATE_AN_ACCOUNT,
        'bool',
        false,
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/dashboard',
        (route) => false,
      );
    } else if (result is String) {
      ErrorDialog.displayErrorDialog(context, result);
    }
  }

  void _validateValues() {
    if (_emailOrUsername.value.isEmpty) {
      _emailOrUsername.setError(Constants.ERROR_EMAIL_OR_USERNAME_REQUIRED);
    } else {
      _emailOrUsername.setError(null);
    }

    if (_password.value.isEmpty) {
      _password.setError(Constants.ERROR_PASSWORD_REQUIRED);
    } else {
      _password.setError(null);
    }
  }

  Future<void> _handleFormSubmission() async {
    setState(() => _submitting = true);

    _validateValues();

    if (_emailOrUsername.isValid() && _password.isValid()) {
      var email, foundUser;
      final bool isEmail =
          Constants.emailRegex.hasMatch(_emailOrUsername.value);

      // Does an account already exist with the email or username?
      if (isEmail) {
        email = _emailOrUsername.value;
        foundUser = await _databaseService.getUserWithEmail(email);

        // If the users username is empty, than the account was saved in the datbase from a Google authentication initially.
        // Prompt the user: Sign into your existing Google account?
        if (foundUser != null && foundUser.data['username'].isEmpty) {
          _displaySignIntoExistingGoogleAccountDialog();
          return;
        }
      }

      // Does an account already exist with the username?
      if (!isEmail) {
        foundUser = await _databaseService.getUserWithUsername(
          _emailOrUsername.value,
        );

        // No user is found first with an email, then with a username, so display the error dialog
        if (foundUser == null) {
          FocusScope.of(context).requestFocus(FocusNode());
          ErrorDialog.displayErrorDialog(
            context,
            Constants.ERROR_USER_NOT_FOUND,
          );
          setState(() => _submitting = false);
          return;
        }

        // else, get the email from the foundUser and set it to the local property
        // to sign in with to Firebase.
        email = foundUser.data['email'];
      }

      if (foundUser != null) {
        // TODO: moved in the above if block finding a user with an email as the logic only applies
        //       in that block, as the following block then searches for a user with a username and
        //       this code checks if a username is empty which is impossible.
        // // Sign into your existing Google account?
        // if (findUserResponse.data['username'] == '' ||
        //     findUserResponse.data['username'].isEmpty) {
        //   _displaySignIntoExistingGoogleAccountDialog();
        //   return;
        // }

        // The account was created with an email and password and not Google
        final authResult = await _authService.signInWithEmailAndPassword(
          email: email,
          password: _password.value,
        );

        // success
        if (authResult is AuthResult) {
          store.dispatch(
            SetLoadingValuesAction(
              isOpen: true,
              showIcon: store.state.loadingState.showIcon,
              title: store.state.loadingState.title,
              text: store.state.loadingState.text,
            ),
          );

          store.dispatch(
            SetUserValuesAction(
              uid: authResult.user.uid,
              email: foundUser.data['email'],
              username: foundUser.data['username'],
              nickname: foundUser.data['nickname'],
              phoneNumber: foundUser.data['phoneNumber'],
              platform: foundUser.data['platform'],
            ),
          );

          setState(() => _submitting = false);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
          );
        } else {
          // error
          store.dispatch(
            SetLoadingValuesAction(
              isOpen: false,
              showIcon: store.state.loadingState.showIcon,
              title: store.state.loadingState.title,
              text: store.state.loadingState.text,
            ),
          );
          ErrorDialog.displayErrorDialog(context, authResult);
          setState(() => _submitting = false);
        }
      }
    } else {
      setState(() => _submitting = false);
    }
  }

  Future<void> _handleSignIntoExistingGoogleAccountAnswer(bool yes) async {
    if (yes) {
      final AuthCredential authCredential =
          await _authService.beginSignInWithGoogle();
      final authResult =
          await _authService.signInWithCredential(authCredential);
      if (authResult is AuthResult) {
        var storedUser = await _databaseService.getUserWithUID(
          authResult.user.uid,
        );
        storedUser = storedUser.data;

        if (storedUser is Map) {
          store.dispatch(
            SetUserValuesAction(
              email: storedUser['email'],
              username: storedUser['username'],
              nickname: storedUser['nickname'],
              phoneNumber: storedUser['phoneNumber'],
              platform: Constants.GOOGLE,
            ),
          );
        }
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
        );
      } else if (authResult is String) {
        // error
        ErrorDialog.displayErrorDialog(context, authResult.toString());
        setState(() => _submitting = false);
      }
    } else {
      _emailOrUsername
          .setError(Constants.ERROR_ACCOUNT_EXISTS_WITH_EMAIL_ADDRESS);

      setState(() => _submitting = false);
    }
  }

  Future<void> _displaySignIntoExistingGoogleAccountDialog() async {
    /**
     * 
     */
    final AppTheme theme = Provider.of(context, listen: false);
    final styles = Styles.alertDialog;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 15,
                  color: Color.fromRGBO(72, 133, 237, 1),
                ),
              ),
              Expanded(
                child: Container(
                  height: 15,
                  color: Color.fromRGBO(219, 50, 54, 1),
                ),
              ),
              Expanded(
                child: Container(
                  height: 15,
                  color: Color.fromRGBO(244, 194, 13, 1),
                ),
              ),
              Expanded(
                child: Container(
                  height: 15,
                  color: Color.fromRGBO(60, 186, 84, 1),
                ),
              ),
            ],
          ),
          titlePadding: EdgeInsets.all(0),
          backgroundColor: theme.background,
          buttonPadding: EdgeInsets.all(20),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Text(
                  'A Google account is already linked to that email.',
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Would you like to sign in with your Google account?',
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              padding: EdgeInsets.all(0),
              child: Text(
                'YES',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: styles['actions']['flatButton']['text']
                      ['fontWeight'],
                  color: theme.onBackground,
                ),
              ),
              onPressed: () async {
                await _handleSignIntoExistingGoogleAccountAnswer(true);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              padding: EdgeInsets.all(0),
              child: Text(
                'NO',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: styles['actions']['flatButton']['text']
                      ['fontWeight'],
                  color: theme.onBackground,
                ),
              ),
              onPressed: () async {
                await _handleSignIntoExistingGoogleAccountAnswer(false);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppTheme theme = Provider.of<AppTheme>(context);

    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        Widget widget;
        if (state.loadingState.isOpen) {
          widget = LoadingScreen(
            title: state.loadingState.title ?? null,
            text: state.loadingState.text ?? null,
            showIcon: state.loadingState.showIcon ?? null,
          );
        } else {
          widget = WillPopScope(
              child: Scaffold(
                extendBodyBehindAppBar: true,
                appBar: state.loadingState.isOpen
                    ? null
                    : PreferredSize(
                        preferredSize:
                            Size.fromHeight(Constants.APP_BAR_HEIGHT),
                        child: Container(
                          width: size.width,
                          height: Constants.APP_BAR_HEIGHT +
                              Constants.STATUS_BAR_HEIGHT,
                          padding: EdgeInsets.only(left: 16),
                          decoration: BoxDecoration(
                            color: Colors.transparent,

                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.black.withOpacity(0.05),
                            //     blurRadius: 5.0,
                            //     spreadRadius: 5.0,
                            //   ),
                            // ],
                          ),
                          child: Stack(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: size.width,
                                margin: EdgeInsets.only(
                                    top: Constants.STATUS_BAR_HEIGHT),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: Constants.STATUS_BAR_HEIGHT),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Icon(
                                          Icons.arrow_back,
                                          color: theme.primary.withOpacity(
                                            0.75,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                body: Container(
                  padding: EdgeInsets.fromLTRB(
                    size.width * .1,
                    0,
                    size.width * .1,
                    0,
                  ),
                  height: size.height,
                  constraints: BoxConstraints(
                    minHeight: size.height,
                  ),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/black_and_white_mountains.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: OrientationBuilder(
                      builder: (context, orientation) {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: Constants.STATUS_BAR_HEIGHT +
                                      Constants.APP_BAR_HEIGHT,
                                ),
                                WelcomeText(leadingText: 'Login'),
                                SizedBox(height: 48),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    LoginForm(
                                      formKey: _formKey,
                                      formControls: [
                                        _emailOrUsername,
                                        _password
                                      ],
                                      signInWithCredentials:
                                          _handleFormSubmission,
                                      signInWithGoogle: signInWithGoogle,
                                      isSendingRequest: _submitting,
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, '/password-reset');
                                          },
                                          child: Text(
                                            'Forgot password?',
                                            style: TextStyle(
                                              color: theme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 32),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: SubmitButton(
                                            text: 'Next',
                                            isSubmitting: _submitting,
                                            formIsValid: _formIsValid,
                                            handleOnSubmit:
                                                _handleFormSubmission,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: RaisedButton.icon(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            padding: EdgeInsets.fromLTRB(
                                                10, 15, 10, 15),
                                            // shape: RoundedRectangleBorder(
                                            //     borderRadius:
                                            //         BorderRadius.circular(100.0)),
                                            color: theme.primaryVariant,
                                            icon: Icon(Icons.phone_android,
                                                color: theme.onPrimaryVariant
                                                    .withOpacity(0.8)),
                                            onPressed: () =>
                                                Navigator.pushNamed(
                                              context,
                                              '/verify-phone',
                                            ),
                                            label: Text(
                                              'Login With Your Phone',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: theme.onPrimaryVariant
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              onWillPop: () async {
                await Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );

                return;
              });
        }

        return widget;
      },
    );
  }
}
