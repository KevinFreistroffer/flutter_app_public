import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../widgets/loading_screen/LoadingScreen.dart';
import '../../widgets/submit_button.dart';
import '../../widgets/form_input.dart';
import '../../services/loading.service.dart';
import '../../services/authentication.service.dart';
import '../../services/storage.service.dart';
import '../../services/database.service.dart';
import '../../services/user.service.dart';
import '../../constants.dart';
import '../../theme.dart';
import '../enter_phone_number/enter_phone_number.dart';
import '../enter_sms_code/enter_sms_code.dart';
import './styles.dart';
import '../../wait.dart';
import '../../error_dialog.dart';

import '../../state/user_model.dart';

class VerifyPhone extends StatefulWidget {
  VerifyPhone({Key key}) : super(key: key);

  @override
  _VerifyPhoneState createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  final LoadingService _loadingService = LoadingService();
  final AuthenticationService _authService = AuthenticationService();
  final StorageService _storageService = StorageService();
  final DatabaseService _databaseService = DatabaseService();
  final UserService _userService = UserService();
  UserModel _userModel;
  PageController _pageController;
  int _currentPage = 0;
  bool _submitting = false;
  Map<String, dynamic> _formValues = {
    'phone': '',
    'smsCode': '',
  };
  Map<String, dynamic> _errors = {
    'phone': null,
    'smsCode': null,
  };
  double _enterPhoneOpacity = 1;
  double _codeSentOpacity = 0;
  bool _enterPhoneIsVisible = true;
  bool _codeSentIsVisible = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPage,
      keepPage: true,
    );

    _authService.phoneAuthenticationController.stream.listen((data) {
      // Success auto verified
      if (data['phoneVerificationSucceeded']) {
        wait(s: 2).then((_) async {
          // await _storageService.set(
          //   'signedInPlatform',
          //   'String',
          //   Constants.PHONE,
          // );

          await _userService.attemptToSetUsernameInCache();

          _loadingService.add(isOpen: true);
          await wait(s: 2);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
          );
        });
      } else if (data['verificationID'].isNotEmpty &&
          data['forceResendingToken'] != null) {
        setState(() => _enterPhoneOpacity = 0);
        wait(s: 1).then((_) async {
          setState(() {
            _enterPhoneIsVisible = false;
            _codeSentIsVisible = true;
          });
        });
        wait(ms: 500).then((value) => setState(() => _codeSentOpacity = 1));
      } else if (data['error'] != null) {
        ErrorDialog.displayErrorDialog(context, data['error']);
      }
    });
  }

  @override
  void didChangeDependecies() {
    super.didChangeDependencies();
    _userModel = Provider.of<UserModel>(context, listen: false);
  }

  _handleFormInputsOnChange(String name, String value) {
    setState(() {
      _formValues[name] = value.trim();
      _errors[name] = value.isNotEmpty ? null : _errors[name];
    });
  }

  _validateValues() {
    if (_currentPage == 0) {
      if (_formValues['phone'].isEmpty) {
        setState(
          () => _errors['phone'] = Constants.ERROR_PHONE_NUMBER_REQUIRED,
        );
      } else if (_formValues['phone'].length < 10) {
        setState(() => _errors['phone'] = Constants.ERROR_INVALID_PHONE_NUMBER);
      } else {
        setState(() => _errors['phone'] = null);
      }
    } else {
      if (_formValues['smsCode'].isEmpty) {
        setState(() => _errors['smsCode'] = Constants.ERROR_SMS_CODE_REQUIRED);
      } else if (_formValues['smsCode'].length < 6) {
        setState(
            () => _errors['smsCode'] = Constants.ERROR_SMS_CODE_INVALID_FORMAT);
      } else {
        setState(() => _errors['smsCode'] = null);
      }
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _submitting = true);

    _validateValues();

    // Enter Phone Number
    if (_currentPage == 0) {
      if (_errors['phone'] == null) {
        // Set cached values. Should be added to streams or similar.
        await _storageService.set('phoneVerificationInProgress', 'bool', true);
        // await _storageService.set(
        //   'phoneNumber',
        //   'String',
        //   '+1${_formValues['phone']}',
        // );
        _authService.verifyPhoneNumber(
          phoneNumber: '+1${_formValues['phone']}',
        );
      } else {
        // ... form displays error
      }
    }

    // Enter SMS Code
    if (_currentPage == 1) {
      if (_errors['smsCode'] == null) {
        String verificationID = await _storageService.get('verificationID');
        AuthCredential authCredential;
        try {
          authCredential = _authService.getCredential(
            verificationID,
            _formValues['smsCode'],
          );
        } catch (error) {
          ErrorDialog.displayErrorDialog(context, error.toString());
        }

        try {
          final authResult = await _authService.signInWithCredential(
            authCredential,
          );

          // _storageService.set('uid', 'String', authResult.user.uid);
          await _storageService.removeMultiple([
            'phoneVerificationInProgress',
            'phoneNumber',
            'verificationID',
            'forceResendingToken'
          ]);

          await _storageService.set(
            Constants.PROMPTED_TO_CREATE_AN_ACCOUNT,
            'bool',
            false,
          );
          // await _storageService.set(
          //   'signedInPlatform',
          //   'String',
          //   Constants.PHONE,
          // );
          //var platform = await _storageService.get('signedInPlatform');

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
          );
        } catch (error) {
          String errorMessage;
          if (error.toString().contains('ERROR_INVALID_CREDENTIAL')) {
            errorMessage = Constants.ERROR_INVALID_CREDENTIAL;
          } else if (error.toString().contains('ERROR_USER_DISABLED')) {
            errorMessage = Constants.ERROR_USER_DISABLED;
          } else if (error
              .toString()
              .contains('ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL')) {
            errorMessage =
                Constants.ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL;
          } else if (error.toString().contains('ERROR_OPERATION_NOT_ALLOWED')) {
            errorMessage = Constants.ERROR_OPERATION_NOT_ALLOWED;
          } else if (error
              .toString()
              .contains('ERROR_INVALID_VERIFICATION_CODE')) {
            errorMessage = Constants.ERROR_INVALID_VERIFICATION_CODE;
          }
          ErrorDialog.displayErrorDialog(context, errorMessage.toString());
        }
      } else {
        // ... form displays error
      }
    }

    setState(() => _submitting = false);
  }

  Future<void> _resendSMSCode() async {
    // TODO obtain these from the stream
    final String phoneNumber = await _storageService.get('phoneNumber');
    final int forceResendingToken = await _storageService.get(
      'forceResendingToken',
    );
    _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppTheme theme = Provider.of<AppTheme>(context);

    return Consumer<UserModel>(
      builder: (context, user, child) {
        return StreamBuilder(
          stream: _loadingService.controller.stream,
          builder: (context, snapshot) {
            Widget _widget;
            if (snapshot.hasData && snapshot.data['isOpen']) {
              _widget = LoadingScreen(
                title: snapshot.data['title'],
                text: snapshot.data['text'],
                size: snapshot.data['size'],
                showIcon: snapshot.data['showIcon'],
                showSuccessIcon: snapshot.data['showSuccessIcon'],
              );
            } else {
              _widget = Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  title: Text(
                    '${_currentPage == 0 ? 'Enter Phone Number' : 'Enter SMS Code'}',
                  ),
                  centerTitle: true,
                ),
                body: OrientationBuilder(
                  builder: (context, orientation) {
                    return SingleChildScrollView(
                      child: Container(
                        height: size.height - Constants.APP_BAR_HEIGHT,
                        padding: EdgeInsets.fromLTRB(
                          size.width * .06,
                          0,
                          size.width * .06,
                          0,
                        ),
                        color: theme.background,
                        child: Form(
                          child: PageView(
                            controller: _pageController,
                            physics: NeverScrollableScrollPhysics(),
                            onPageChanged: (int pageIndex) {
                              setState(() => _currentPage = pageIndex);
                            },
                            children: <Widget>[
                              Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Visibility(
                                      visible: _enterPhoneIsVisible,
                                      child: AnimatedOpacity(
                                        opacity: _enterPhoneOpacity,
                                        duration: Duration(milliseconds: 500),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Phone Number',
                                              style: TextStyle(
                                                  fontSize: 25,
                                                  color: theme.onBackground),
                                            ),
                                            SizedBox(height: 8),
                                            TextFormField(
                                              decoration: InputDecoration(
                                                labelText: 'Phone number',
                                                prefixText: '+1',
                                                border: OutlineInputBorder(),
                                                errorText: _errors['phone'],
                                                errorStyle: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 15,
                                                  letterSpacing: 0.2,
                                                  // backgroundColor: Colors.white.withOpacity(0.2),
                                                ),
                                                errorMaxLines: 3,
                                              ),
                                              onChanged: (String value) {
                                                _handleFormInputsOnChange(
                                                  'phone',
                                                  value,
                                                );
                                              },
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'if you use your phone number, you might receive an SMS message for verification and standard rates apply.',
                                              style: TextStyle(
                                                color: theme.onBackground
                                                    .withOpacity(0.75),
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: RaisedButton(
                                                    child: Text(
                                                      'Get code',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                        FocusNode(),
                                                      );
                                                      _handleSubmit();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: _codeSentIsVisible,
                                      child: AnimatedOpacity(
                                        duration: Duration(milliseconds: 500),
                                        opacity: _codeSentOpacity,
                                        child: GestureDetector(
                                          onTap: () {
                                            _pageController.jumpToPage(1);
                                          },
                                          child: Column(
                                            children: <Widget>[
                                              Text(
                                                'We will send a One Time Password to this mobile number',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: theme.onBackground,
                                                ),
                                              ),
                                              Flex(
                                                direction: Axis.vertical,
                                                children: <Widget>[
                                                  Expanded(
                                                    child: RaisedButton(
                                                      child: Text('Enter Code'),
                                                      onPressed: () {
                                                        _loadingService.add(
                                                            isOpen: true);
                                                        setState(() {
                                                          _codeSentIsVisible =
                                                              false;
                                                          _codeSentOpacity = 0;
                                                          _enterPhoneIsVisible =
                                                              true;
                                                          _enterPhoneOpacity =
                                                              1;
                                                        });
                                                        _pageController
                                                            .nextPage(
                                                          duration: Duration(
                                                              milliseconds:
                                                                  215),
                                                          curve:
                                                              Curves.elasticIn,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: size.width,
                                height: size.height - Constants.APP_BAR_HEIGHT,
                                color: theme.background,
                                padding: EdgeInsets.fromLTRB(
                                  size.width * .1,
                                  size.width * .125,
                                  size.width * .1,
                                  size.width * .125,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Please enter the SMS Code Sent To Your Phone',
                                      style: TextStyle(fontSize: 35.0),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                        'To make sure this number is yours, we will send you a text message with a 6-digit verification code. Standard rates apply',
                                        style: TextStyle(
                                          fontSize: 20,
                                        )),
                                    SizedBox(height: 16),
                                    Form(
                                      //key: _store.phoneNumberFormKey,
                                      child: Column(
                                        children: <Widget>[
                                          TextField(
                                            decoration: InputDecoration(
                                              labelText: 'SMS Code',
                                              border: OutlineInputBorder(),
                                              errorText: _errors['smsCode'],
                                              errorStyle: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                letterSpacing: 0.2,
                                                // backgroundColor: Colors.white.withOpacity(0.2),
                                              ),
                                              errorMaxLines: 3,
                                            ),
                                            onChanged: (String value) {
                                              _handleFormInputsOnChange(
                                                'smsCode',
                                                value,
                                              );
                                            },
                                            keyboardType: TextInputType.number,
                                            maxLength: 6,
                                          ),
                                          SizedBox(height: 16),
                                          SubmitButton(
                                            text: 'Next',
                                            handleOnSubmit: _handleSubmit,
                                            isSubmitting: _submitting,
                                            formIsValid:
                                                _errors['phone'] == null,
                                          ),
                                          SizedBox(height: 16),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: RaisedButton(
                                                  color: theme.secondary
                                                      .withOpacity(0.7),
                                                  child: Text(
                                                    'Resend Code',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                      FocusNode(),
                                                    );
                                                    _resendSMSCode();
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
      },
    );
  }
}
