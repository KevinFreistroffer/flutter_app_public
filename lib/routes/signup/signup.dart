import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import '../../models/new_user.dart';
import 'styles.dart';
import '../../services/authentication.service.dart';
import '../../services/database.service.dart';
import '../../services/storage.service.dart';
import '../../services/loading.service.dart';
import '../../constants.dart';
import '../../widgets/loading_screen/LoadingScreen.dart';
import 'step_email_and_username.dart';
import 'step_passwords.dart';
import '../../theme.dart';
import '../../wait.dart';
import '../../error_dialog.dart';
import '../../form_control.dart';

import '../../state/user_model.dart';

class SignUp extends StatefulWidget {
  SignUp({Key key}) : super(key: key);

  @override
  SignUpState createState() => SignUpState();
}

abstract class Step {
  Map _errors;

  void setInitialErrorValues(Map keyValues) {
    _errors = keyValues;
    print('setInitialValues $_errors');
  }

  Map get errors => _errors;

  void setError(Map keyValue) {
    // updateAll() ?
    keyValue.forEach((key, value) {
      _errors[key] = value;
    });
  }

  bool isValid() => _errors.entries.every(
        (MapEntry entry) {
          return entry.value.isEmpty;
        },
      );
}

abstract class FormControl2 {
  dynamic _value;
  dynamic _error;

  dynamic get error => _error;
  dynamic get value => _value;

  void setError(value) => _error = value;
  void setValue(value) => _value = value;

  bool isValid() => _error == null;
}

class EmailAndUsername extends Step {}

class Passwords extends Step {}

class Email extends FormControl2 {}

class Username extends FormControl2 {}

class Password extends FormControl2 {}

class ConfirmPassword extends FormControl2 {}

class SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>();
  final AuthenticationService _authService = AuthenticationService();
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  final LoadingService _loadingService = LoadingService();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final StreamController _emailAsUsernameStreamController =
      StreamController<bool>.broadcast();
  EmailAndUsername _emailAndUsername;
  Passwords _passwords;
  Email _email;
  Username _username;
  Password _password;
  ConfirmPassword _confirmPassword;
  UserModel _userModel;
  PageController _pageController;
  String _cachedValidEmail = '';
  String _cachedValidUsername = '';
  bool _emailAndUsernameValidated = false;
  bool _submitting = false;
  List<Step> _steps = [];
  Step _currentStep;
  int _currentPage;

  Map<String, String> _formValues = {
    'email': '',
    'username': '',
    'password': '',
    'confirmPassword': '',
  };

  SignUpState() {
    _emailAndUsername = EmailAndUsername()
      ..setInitialErrorValues({'email': '', 'username': ''});
    _passwords = Passwords()
      ..setInitialErrorValues({'password': '', 'confirmPassword': ''});

    _email = Email()
      ..setValue('')
      ..setError(null);
    _username = Username()
      ..setValue('')
      ..setError(null);
    _password = Password()
      ..setValue('')
      ..setError(null);
    _confirmPassword = ConfirmPassword()
      ..setValue('')
      ..setError(null);
  }

  @override
  void initState() {
    super.initState();
    _steps.addAll([_emailAndUsername, _passwords]);

    _pageController = PageController(initialPage: 0, keepPage: true);
    _currentStep = _steps[0];
    _currentPage = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userModel = Provider.of<UserModel>(context, listen: false);
  }

  void _handleInputOnChanged(String name, String value) {
    switch (name) {
      case 'email':
        _email.setValue(value.trim());
        _email.setError(value.isNotEmpty ? null : _email.error);
        break;

      case 'username':
        _username.setValue(value.trim());
        _username.setError(value.isNotEmpty ? null : _username.error);
        break;

      case 'password':
        _password.setValue(value.trim());
        _password.setError(value.isNotEmpty ? null : _password.error);
        break;

      case 'confirmPassword':
        _confirmPassword.setValue(value.trim());
        _confirmPassword
            .setError(value.isNotEmpty ? null : _confirmPassword.error);
        break;
      default:
        break;
    }

    setState(() {
      _formValues[name] = value.trim();

      if (_currentStep is EmailAndUsername) {
        _emailAndUsername.setError(
          {name: value.isNotEmpty ? '' : _emailAndUsername.errors[name]},
        );
      } else {
        _passwords.setError(
          {name: value.isNotEmpty ? '' : _passwords.errors[name]},
        );
      }
    });
  }

  bool _currentStepIsValidAndNotDirty(Step step) {
    return step is EmailAndUsername &&
        _emailAndUsernameValidated &&
        _email.value == _cachedValidEmail &&
        _username.value == _cachedValidUsername;
  }

  Future<void> _handleFormSubmission(Step step) async {
    setState(() => _submitting = true);

    if (_currentStepIsValidAndNotDirty(step)) {
      _pageController.jumpToPage(_currentPage + 1);
      setState(() => _submitting = false);

      return;
    }

    _validateValues();

    if (step is EmailAndUsername) {
      if (_email.isValid() && _username.isValid()) {
        if (EmailValidator.validate(_formValues['username'])) {
          _displayEmailAsUsernameDialog();
          setState(() => _submitting = false);

          if (!await _emailAsUsernameStreamController.stream.first) {
            return;
          }
        }

        final List snapshots = await _emailAndUsernameAreUnique();
        print('snapshots $snapshots');

        // Email and username are available to sign up
        if (snapshots.every((snapshot) => snapshot == null)) {
          setState(() {
            //_errors['form'] = null;
            _cachedValidEmail = _email.value;
            _cachedValidUsername = _username.value;
            _submitting = false;
            _emailAndUsernameValidated = true;
          });

          _pageController.jumpToPage(_currentPage + 1);

          return;
        } else {
          if (snapshots[0] != null) {
            if (snapshots[0].data['username'] == "''" ||
                snapshots[0].data['username'].isEmpty) {
              _displaySignIntoExistingGoogleAccountDialog();
            } else {
              ErrorDialog.displayErrorDialog(context,
                  Constants.ERROR_ACCOUNT_EXISTS_WITH_EMAIL_OR_USERNAME);
            }
          } else {
            // setState(
            //   () => _errors['form'] =
            //       Constants.ERROR_ACCOUNT_EXISTS_WITH_EMAIL_OR_USERNAME,
            // );

            // _displayErrorDialog(_errors['form'], barrierDismissible: true);
          }
        }
      } else {
        setState(() => _submitting = false);
      }
    }

    if (step is Passwords) {
      if (_password.isValid() && _confirmPassword.isValid()) {
        // _loadingService.add(isOpen: true, );

        // _databaseService.updateUser(password: _formValues['password']);
        // Firebase signs the user in. They're authenticated.
        final dynamic authResult =
            await _databaseService.createUserWithEmailAndPassword(
          _email.value,
          _password.value,
        );

        if (authResult is AuthResult) {
          _userModel.set(uid: authResult.user.uid);
          // success

          final createResponse =
              await _databaseService.createUserWithAdditionalProperties(
            NewUser(
              uid: authResult.user.uid,
              email: _email.value,
              username: _username.value,
              nickname: '',
              phoneNumber: authResult.user.phoneNumber ?? '',
              platform: Constants.EMAIL_OR_USERNAME,
            ),
          );

          if (createResponse is DocumentReference) {
            _userModel.set(
              uid: authResult.user.uid,
              email: _email.value,
              username: _username.value,
              nickname: '',
              phoneNumber: authResult.user.phoneNumber ?? '',
              platform: Constants.EMAIL_OR_USERNAME,
            );
          } else {
            ErrorDialog.displayErrorDialog(context, createResponse.toString());
            return;
          }
        } else if (authResult is String) {
          ErrorDialog.displayErrorDialog(context, authResult);

          return;
        }

        // Wait 2.3 seconds
        await wait(ms: 2300);
        setState(() => _submitting = false);
        _loadingService.add(isOpen: true);

        await wait(ms: 5500);

        setState(() => _submitting = false);
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (_) => false,
        );
      }

      setState(() => _submitting = false);
    }
  }

  Future<void> _validateValues() async {
    // Username and email
    if (_currentStep is EmailAndUsername) {
      if (_email.value.isEmpty) {
        _email.setError(Constants.ERROR_EMAIL_REQUIRED);
      } else if (!EmailValidator.validate(_email.value)) {
        _email.setError(Constants.ERROR_INVALID_EMAIL);
      } else {
        _email.setError(null);
      }
      if (_username.value.isEmpty) {
        _username.setError(Constants.ERROR_USERNAME_REQUIRED);
      } else {
        _username.setError(null);
      }
    } // Username and email

    // Password and confirmPassword
    if (_currentStep is Passwords) {
      if (_password.value.isEmpty) {
        _password.setError(Constants.ERROR_PASSWORD_REQUIRED);
      } else if (_password.value.length < 6) {
        _password.setError(Constants.ERROR_PASSWORD_TOO_SHORT);
      } else {
        _password.setError(null);
      }

      if (_confirmPassword.value.isEmpty) {
        _confirmPassword
            .setError(Constants.ERROR_CONFIRM_YOUR_PASSWORD_REQUIRED);
      } else if (_password.value != _confirmPassword.value) {
        _confirmPassword.setError(Constants.ERROR_PASSWORDS_DONT_MATCH);
      } else {
        _confirmPassword.setError(null);
      }
    } // Password and confirmPassword

    setState(() {});
  }

  Future<List> _emailAndUsernameAreUnique() async {
    final emailSnapshot =
        await _databaseService.findUserWithEmail(_email.value);
    final usernameSnapshot =
        await _databaseService.getUserWithUsername(_username.value);

    return [emailSnapshot, usernameSnapshot];
  }

  Future<void> _handleSignIntoExistingGoogleAccountAnswer(bool yes) async {
    if (yes) {
      final AuthCredential authCredential =
          await _authService.signInWithGoogle();
      final response = await _authService.signInWithCredential(authCredential);
      if (response is AuthResult) {
        setState(() => _submitting = false);
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
        );
      } else if (response is String) {
        // error
        ErrorDialog.displayErrorDialog(context, response.toString());
      }
    } else {
      _email.setError(Constants.ERROR_ACCOUNT_EXISTS_WITH_EMAIL_ADDRESS);
      setState(() => _submitting = false);
    }
  }

  Future<void> _displayEmailAsUsernameDialog() async {
    final AppTheme theme = Provider.of(context, listen: false);
    final styles = Styles.alertDialog;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Container(
            height: 100,
            color: Colors.red,
            child: null,
          ),
          titlePadding: EdgeInsets.all(0),
          backgroundColor: theme.background,
          buttonPadding: EdgeInsets.all(20),
          content: Text(
            'Are you sure you want to set an email as your username?',
            style: TextStyle(
              fontSize: 25,
              height: 1.5,
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
              onPressed: () {
                _emailAsUsernameStreamController.add(true);
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
              onPressed: () {
                _emailAsUsernameStreamController.add(false);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                SizedBox(height: 18.5),
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
                //Navigator.of(context).pop();
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

    return StreamBuilder(
      stream: _loadingService.controller.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        Widget _widget;
        if (snapshot.hasData) {
          print(snapshot.data);

          if (snapshot.hasData && snapshot.data['isOpen']) {
            _widget = LoadingScreen(
              title: snapshot.data['title'],
              text: snapshot.data['text'],
              size: snapshot.data['size'],
              showIcon: snapshot.data['showIcon'],
              showSuccessIcon: snapshot.data['showSuccessIcon'],
            );
          } else if (snapshot.data['isSigningOut']) {
            _widget = LoadingScreen(title: 'Signing You Out', showIcon: false);
          }
        } else {
          _widget = Scaffold(
            backgroundColor: Colors.white,
            appBar: null,
            body: OrientationBuilder(
              builder: (context, orientation) {
                return SingleChildScrollView(
                  child: Container(
                    height: size.height,
                    child: Form(
                      child: PageView(
                        controller: _pageController,
                        physics: NeverScrollableScrollPhysics(),
                        onPageChanged: (int pageIndex) {
                          setState(
                            () {
                              _currentStep = _steps[pageIndex];
                              _currentPage = pageIndex;
                            },
                          );
                        },
                        children: <Widget>[
                          EmailAndUsernameStep(
                            key: new PageStorageKey('emailAndUsername'),
                            usernameTextController: usernameController,
                            emailTextController: emailController,
                            pageController: _pageController,
                            emailAndUsername: _emailAndUsername,
                            email: _email,
                            username: _username,
                            errors: _emailAndUsername.errors,
                            submitting: _submitting,
                            handleOnChanged: _handleInputOnChanged,
                            handleOnSubmit: _handleFormSubmission,
                          ),
                          PasswordsStep(
                            key: new PageStorageKey('passwords'),
                            pageController: _pageController,
                            password: _password,
                            confirmPassword: _confirmPassword,
                            // passwords: _passwords,
                            submitting: _submitting,
                            handleOnChanged: _handleInputOnChanged,
                            handleOnSubmit: _handleFormSubmission,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return _widget;
      },
    );
  }
}

typedef FormSubmission<T> = void Function(Step step);
typedef InputChangeValue<T> = void Function(String name, String value);
