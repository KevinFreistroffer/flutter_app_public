import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../constants.dart';
import '../../services/authentication.service.dart';
import '../../services/authentication.service.dart';
import '../../services/storage.service.dart';
import '../../widgets/submit_button.dart';
import '../../error_dialog.dart';
import './styles.dart';

class EnterPhoneNumber extends StatefulWidget {
  EnterPhoneNumber({
    Key key,
  }) : super(key: key);

  @override
  _EnterPhoneNumberState createState() => _EnterPhoneNumberState();
}

class _EnterPhoneNumberState extends State<EnterPhoneNumber> {
  final AuthenticationService _authService = AuthenticationService();
  final StorageService _storageService = StorageService();
  String _phoneNumber = '';
  dynamic _error;

  @override
  void initState() {
    super.initState();

    _authService.phoneAuthenticationController.stream.listen((data) {
      if (data['forceResendingToken'] is int) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/enter-sms-code',
          (route) => false,
        );
      }
    });
  }

  _handleFormInputOnChange(String value) {
    if (value.trim().isNotEmpty &&
        value == Constants.ERROR_PHONE_NUMBER_REQUIRED) {
      setState(() => _error = null);
    }

    setState(() => _phoneNumber = value);
  }

  _validatePhoneNumber() {
    if (_phoneNumber.isEmpty) {
      setState(() => _error = Constants.ERROR_PHONE_NUMBER_REQUIRED);
    } else if (_phoneNumber.length < 10) {
      setState(() => _error = Constants.ERROR_INVALID_PHONE_NUMBER);
    } else {
      setState(() => _error = null);
    }
  }

  Future<void> _handleSubmit() async {
    _validatePhoneNumber();

    if (_error == null) {
      await _storageService.set('phoneVerificationInProgress', 'bool', true);
      await _storageService.set('phoneNumber', 'String', '+1$_phoneNumber');
      _authService.verifyPhoneNumber(phoneNumber: '+1$_phoneNumber');
    } else {
      ErrorDialog.displayErrorDialog(context, _error);
    }
  }

  Future<void> verificationCompletedCallback(
      AuthCredential authCredential) async {
    var result = await _authService.signInWithCredential(authCredential);
    if (result is AuthResult) {
      // success
      // save user details
      await _storageService.set('uid', 'String', result.user.uid);
      // Need this
      //_storageService.set('username', 'String', result.user);
      await _storageService.remove('phoneVerificationInProgress');
    } else if (result is String) {
      // error
      ErrorDialog.displayErrorDialog(context, result.toString());
    }
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Cancel registration?'),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Text('Are you sure you want to cancel signing in?'),
                  Row(
                    children: <Widget>[],
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                ),
              ),
            ],
          ) ??
          false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppTheme theme = Provider.of<AppTheme>(context);

    return StreamBuilder(
      initialData: {
        'phoneVerificationInProgress': false,
        'phoneVerificationSucceeded': false,
        'phoneVerificationFailed': false,
        'authCredential': null,
        'error': '',
        'verificationID': '',
        'forceResendingToken': null,
      },
      stream: _authService.phoneAuthenticationController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        Map data = snapshot.data;

        // Autocomplete

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Text(
              'Enter Phone Number',
              style: TextStyle(
                color: theme.onBackground,
              ),
            ),
            centerTitle: true,
          ),
          body: OrientationBuilder(
              builder: (BuildContext context, Orientation orientation) {
            return Container(
                height: size.height - Constants.APP_BAR_HEIGHT,
                width: size.width,
                padding: EdgeInsets.fromLTRB(
                    size.width * 0.0625, 0, size.width * 0.0625, 0),
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      0,
                      // size.width * .06,
                      size.height * .12,
                      0,
                      // size.width * .06,
                      size.height * .12,
                    ),
                    color: theme.background,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'We will send a One Time Password to this mobile number',
                            style: TextStyle(
                              fontSize: 20,
                              color: theme.onBackground,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Phone number',
                              prefixText: '+1',
                              border: OutlineInputBorder(),
                              errorText: _error,
                              errorStyle: TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                                letterSpacing: 0.2,
                                // backgroundColor: Colors.white.withOpacity(0.2),
                              ),
                              errorMaxLines: 3,
                            ),
                            onChanged: _handleFormInputOnChange,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: 16),
                          Text(
                              'if you use your phone number, you might receive an SMS message for verification and standard rates apply.',
                              style: TextStyle(
                                  color: theme.onBackground.withOpacity(0.75))),
                          SizedBox(height: 16),
                          Container(
                            width: size.width,
                            constraints: BoxConstraints(
                              maxWidth: 290,
                            ),
                            child: RaisedButton(
//padding: EdgeInsets.all(10),
                              // shape: RoundedRectangleBorder(
                              //   borderRadius: BorderRadius.circular(100.0),
                              // ),
                              child: Text('Get fdasfasdfcode',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  )),
                              onPressed: () {
                                FocusScope.of(context).requestFocus(
                                  FocusNode(),
                                );
                                _handleSubmit();
                              },
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            //width: 150,
                            child: GestureDetector(
                              // padding: EdgeInsets.all(10),
                              // color: Theme.of(context)
                              //     .primaryColor
                              //     .withOpacity(0.75),
                              // shape: RoundedRectangleBorder(
                              //   borderRadius: BorderRadius.circular(100.0),
                              // ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                Navigator.pushNamed(context, '/login');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ));
          }),
        );
      },
    );
  }
}
