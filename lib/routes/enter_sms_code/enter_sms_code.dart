import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../services/authentication.service.dart';
import '../../services/database.service.dart';
import '../../services/storage.service.dart';
import './styles.dart';
import '../../models/user_model.dart';
import '../../error_dialog.dart';

class EnterSMSCode extends StatefulWidget {
  EnterSMSCode({
    Key key,
  }) : super(key: key);

  @override
  _EnterSMSCodeState createState() => _EnterSMSCodeState();
}

class _EnterSMSCodeState extends State<EnterSMSCode> {
  final AuthenticationService _authService = AuthenticationService();
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  UserModel _userModel;
  String _smsCode = '';
  dynamic _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userModel = Provider.of<UserModel>(context, listen: false);
  }

  _handleFormInputOnChange(String value) {
    if (value.trim().isNotEmpty && value == Constants.ERROR_SMS_CODE_REQUIRED) {
      setState(() => _error = null);
    }

    setState(() => _smsCode = value);
  }

  _validateSMSCode() {
    if (_smsCode.isEmpty) {
      setState(() => _error = Constants.ERROR_SMS_CODE_REQUIRED);
    } else if (_smsCode.length < 6) {
      setState(() => _error = Constants.ERROR_SMS_CODE_INVALID_FORMAT);
    } else {
      setState(() => _error = null);
    }
  }

  Future<void> _handleSubmit() async {
    _validateSMSCode();

    if (_error == null) {
      // authService build a authCredential using the SMS code and verificationID
      String verificationID = await _storageService.get('verificationID');
      final AuthCredential authCredential = _authService.getCredential(
        verificationID,
        _smsCode,
      );

      try {
        final authResult = await _authService.signInWithCredential(
          authCredential,
        );

        // final foundUserResult = await _databaseService.getUserWithUID(
        //   authResult.user.uid,
        // );
        _userModel.set(uid: authResult.user.uid);
        await _storageService.remove('phoneVerificationInProgress');
        await _storageService.remove('phoneNumber');
        await _storageService.remove('verificationID');
        await _storageService.remove('forceResendingToken');
        await _storageService.set(
          Constants.PROMPTED_TO_CREATE_AN_ACCOUNT,
          'bool',
          false,
        );

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
        ErrorDialog.displayErrorDialog(context, errorMessage);
      }
    }
  }

  Future<void> _resendSMSCode() async {
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('SMS Code'),
      ),
      body: Container(
        height: size.height - Constants.APP_BAR_HEIGHT,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
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
                          errorText: _error,
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
                          _handleFormInputOnChange(value);
                        },
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: 130,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          color: Theme.of(context).accentColor,
                          child: Text(
                            'Verify',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _handleSubmit();
                          },
                        ),
                      ),
                      Container(
                        width: 130,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.8),
                          child: Text(
                            'Resend Code',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _resendSMSCode();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
