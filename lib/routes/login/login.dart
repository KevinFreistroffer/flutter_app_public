import 'dart:async';
import 'dart:collection';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../services/authentication.service.dart';
import '../../services/database.service.dart';
import '../../services/storage.service.dart';
import '../../services/user.service.dart';
import 'form.dart';
import '../../constants.dart';
import '../../widgets/loading_screen/LoadingScreen.dart';
import '../../services/loading.service.dart';
import '../../widgets/submit_button.dart';
import '../../theme.dart';
import 'styles.dart';
import '../../models/user_model.dart';
import '../../error_dialog.dart';
import '../../form_control.dart';

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
  final LoadingService _loadingService = LoadingService();
  final DatabaseService _databaseService = DatabaseService();
  final UserService _userService = UserService();
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
  );

  StepEmailOrUsername _stepEmailOrUsername;
  StepPasswords _stepPasswords;
  EmailOrUsername _emailOrUsername;
  Password _password;
  UserModel _userModel;
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

  @override
  void initState() {
    super.initState();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    _userModel = Provider.of<UserModel>(context, listen: false);
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
      var email, findUserResponse;
      var isEmail = Constants.emailRegex.hasMatch(_emailOrUsername.value);

      /**
       * Does an account already exist with the email or username?
       */
      if (isEmail) {
        email = _emailOrUsername.value;

        findUserResponse = await _databaseService.getUserWithEmail(email);
      }

      if (!isEmail) {
        findUserResponse = await _databaseService.getUserWithUsername(
          _emailOrUsername.value,
        );

        if (findUserResponse == null) {
          FocusScope.of(context).requestFocus(FocusNode());
          ErrorDialog.displayErrorDialog(
            context,
            Constants.ERROR_USER_NOT_FOUND,
          );
          setState(() => _submitting = false);
          return;
        }

        email = findUserResponse.data['email'];
      }

      /**
       * If an account does exist with the email or username, check if the username is empty, and if it is
       * than, the account was created with Google and only contains an email address, and proceed to display the sign
       * into an existing Google account dialog.
       */
      if (findUserResponse != null) {
        print('a user was found. $findUserResponse');
        // Sign into your existing Google account?
        if (findUserResponse.data['username'] == '' ||
            findUserResponse.data['username'].isEmpty) {
          _displaySignIntoExistingGoogleAccountDialog();
          return;
        }

        // The account was created with an email and password and not Google
        final authResult = await _authService.signInWithEmailAndPassword(
          email: email,
          password: _password.value,
        );

        // success
        if (authResult is AuthResult) {
          _loadingService.add(isOpen: true);
          _userModel.set(uid: authResult.user.uid);

          _userModel.set(
            email: findUserResponse.data['email'],
            username: findUserResponse.data['username'],
            nickname: findUserResponse.data['nickname'],
            phoneNumber: findUserResponse.data['phoneNumber'],
            platform: findUserResponse.data['platform'],
          );

          setState(() => _submitting = false);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
          );
        } else {
          // error
          _loadingService.add(isOpen: false);
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
          _userModel.set(
            email: storedUser['email'],
            username: storedUser['username'],
            nickname: storedUser['nickname'],
            phoneNumber: storedUser['phoneNumber'],
            platform: Constants.GOOGLE,
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
          _widget = WillPopScope(
              child: Scaffold(
                appBar: snapshot.data['isOpen']
                    ? null
                    : AppBar(
                        leading: GestureDetector(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/', (route) => false);
                          },
                          child: Icon(Icons.arrow_back),
                        ),
                        centerTitle: true,
                        title: Text(
                          'Login',
                          style: TextStyle(color: theme.onBackground),
                        ),
                        iconTheme: IconThemeData(
                          color: theme.onBackground.withOpacity(0.5),
                        ),
                        backgroundColor: theme.primary,
                      ),
                body: Container(
                  padding: EdgeInsets.fromLTRB(
                    size.width * .1,
                    size.width * .125,
                    size.width * .1,
                    0,
                  ),
                  color: theme.background,
                  height: size.height,
                  child: Center(
                    child: OrientationBuilder(
                      builder: (context, orientation) {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: size.width * .125),
                            child: Stack(
                              children: <Widget>[
                                Visibility(
                                  visible: !_showLoadingScreen &&
                                      _currentStep ==
                                          Constants
                                              .SIGNIN_STEP_EMAIL_OR_USERNAME_AND_PASSWORD,
                                  maintainState: true,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      LoginForm(
                                        formKey: _formKey,
                                        formIsValid: _formIsValid,
                                        formControls: [
                                          _emailOrUsername,
                                          _password
                                        ],
                                        signInWithCredentials:
                                            _handleFormSubmission,
                                        signInWithGoogle: signInWithGoogle,
                                        orientation: orientation,
                                        size: size,
                                        isSendingRequest: _submitting,
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, '/password-reset');
                                            },
                                            child: Text(
                                              'Forgot password?',
                                              style: TextStyle(
                                                color: theme.primaryVariant,
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
              });
        }

        return _widget;
      },
    );
  }
}
