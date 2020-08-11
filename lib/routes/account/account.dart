import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../../services/authentication.service.dart';
import '../../constants.dart';
import '../../widgets/AppBars/signed_in_app_bar.dart';
import '../../widgets/submit_button.dart';
import '../../widgets/loading_screen/LoadingScreen.dart';
import '../../theme.dart';
import '../../state/app_state.dart';
import 'styles.dart';
import 'package:flutter_keto/store.dart';
import 'package:flutter_keto/error_dialog.dart';

class Account extends StatefulWidget {
  Account({Key key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final AuthenticationService _authService = AuthenticationService();
  bool _submitting = false;

  Future<void> _sendPasswordResetEmail(context) async {
    final AppTheme theme = Provider.of(context, listen: false);

    setState(() => _submitting = true);

    _authService.sendPasswordResetEmail(store.state.userState.email).then(
      (value) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            backgroundColor: theme.secondary,
            behavior: SnackBarBehavior.floating,
            content: Text('Password reset link sent!'),
          ),
        );
      },
    ).catchError((error) {
      _displayErrorDialog(error.toString());
    }).whenComplete(
      () => setState(() => _submitting = false),
    );
  }

  Future<void> _deleteAccount() async {
    final FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    firebaseUser.delete();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Future<void> _displayDeleteAccountConfirmationDialog() async {
    final styles = Styles.alertDialog;
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        final Size size = MediaQuery.of(context).size;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: Colors.red[300],
            ),
            padding: EdgeInsets.fromLTRB(
              size.width * .01,
              size.width * .025,
              size.width * .01,
              size.width * .025,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.error,
                  size: 35,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          titlePadding: styles['titlePadding'],
          buttonPadding: styles['buttonPadding'],
          contentPadding: styles['contentPadding'],
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Are you sure you want to delete your account?',
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.4,
                    fontWeight: FontWeight.w100,
                  ),
                ),
                SizedBox(height: 32),
                Text(
                    'This action cannot be undone. This will permanently delete this account.'),
              ],
            ),
          ),
          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  child: Text(
                    'Delete this account',
                    style: TextStyle(
                      fontSize: styles['actions']['flatButton']['text']
                          ['fontSize'],
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                    ),
                  ),
                  onTap: () {
                    _deleteAccount();
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(height: 16),
                GestureDetector(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: styles['actions']['flatButton']['text']
                          ['fontSize'],
                      fontWeight: styles['actions']['flatButton']['text']
                          ['fontWeight'],
                      color: Colors.black45,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _displayErrorDialog(
    String error, {
    bool barrierDismissible = true,
  }) {
    final LineSplitter ls = LineSplitter();
    final styles = ErrorDialogStyles.alertDialog;
    final AppTheme theme = Provider.of<AppTheme>(context);

    // split the string at the \n, output a new Text().SizedBox(height)
    List strings = ls.convert(error);
    strings = strings.map((s) => s.trim()).toList();

    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible, // user must tap button!
      builder: (BuildContext context) {
        final Size size = MediaQuery.of(context).size;
        final isPortrait = size.width <
            size.height; // hacky. how to access orientation? OrientationModel?

        return AlertDialog(
          backgroundColor: theme.primaryVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: Colors.red[300],
            ),
            padding: EdgeInsets.fromLTRB(
              size.width * .1,
              isPortrait ? size.height * .05 : size.height * .025,
              size.width * .1,
              isPortrait ? size.height * .05 : size.height * .025,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.error,
                  size: isPortrait ? 60 : 35,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          titlePadding: styles['titlePadding'],
          buttonPadding: styles['buttonPadding'],
          contentPadding: styles['contentPadding'],
          content: Container(
            constraints: BoxConstraints(
              maxWidth: 150,
            ),
            color: theme.primaryVariant,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  for (var s in strings)
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(s),
                    )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            GestureDetector(
              child: Text(
                'DISMISS',
                style: TextStyle(
                    fontSize: styles['actions']['flatButton']['text']
                        ['fontSize'],
                    fontWeight: styles['actions']['flatButton']['text']
                        ['fontWeight'],
                    color: theme.onPrimaryVariant),
              ),
              onTap: () => Navigator.of(context).pop(),
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
        String displayName =
            state.userState.platform == Constants.EMAIL_OR_USERNAME
                ? state.userState.username
                : state.userState.nickname;

        displayName = displayName.length > Constants.MAX_USERNAME_DISPLAY_LENGTH
            ? '${displayName.substring(0, Constants.MAX_USERNAME_DISPLAY_LENGTH)}...'
            : displayName;

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
                appBar: state.loadingState.isOpen
                    ? null
                    : SignedInAppBar(
                        title: displayName,
                      ),
                body: Container(
                  padding: EdgeInsets.fromLTRB(
                    size.width * 0.05,
                    0,
                    size.width * 0.05,
                    0,
                  ),
                  color: Colors.black12,
                  height: size.height,
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: size.height * 0.05),
                            Card(
                              color: Colors.white,
                              borderOnForeground: true,
                              child: Container(
                                padding: EdgeInsets.all(size.width * 0.075),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        // Icon(Icons.person_pin,
                                        //     size: 50,
                                        //     color: theme.primaryVariant),
                                        // SizedBox(width: 10),
                                        Text(
                                          'ABOUT ME',
                                          style: TextStyle(
                                            fontSize: size.width * .05,
                                            fontWeight: FontWeight.bold,
                                            color: theme.primaryVariant,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 32),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          'UID:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 35.0,
                                              color: theme.primaryVariant),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Flexible(
                                          child: Text(
                                            '${state.userState.uid}',
                                            style: TextStyle(
                                                fontSize: 17.5,
                                                color: theme.primaryVariant),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 32),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          'Email:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 35.0,
                                              color: theme.primaryVariant),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            '${state.userState.email}',
                                            style: TextStyle(
                                                fontSize: 17.5,
                                                color: theme.primaryVariant),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 32),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          'Nickname',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 35.0,
                                              color: theme.primaryVariant),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            '"${state.userState.nickname.isEmpty ? 'Not set' : state.userState.nickname}"',
                                            style: TextStyle(
                                                fontSize: 17.5,
                                                color: theme.primaryVariant),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 32),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Phone',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 35.0,
                                              color: theme.primaryVariant),
                                        ),
                                        Text(
                                          'Number:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 35.0,
                                              color: theme.primaryVariant),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            '"${state.userState.phoneNumber.isEmpty ? 'Not set' : state.userState.phoneNumber}"',
                                            style: TextStyle(
                                                fontSize: 17.5,
                                                color: theme.primaryVariant),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 32),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          'Platform',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 35.0,
                                              color: theme.primaryVariant),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            '${state.userState.platform}',
                                            style: TextStyle(
                                                fontSize: 17.5,
                                                color: theme.primaryVariant),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 32),
                            Visibility(
                              visible: state.userState.platform ==
                                  Constants.EMAIL_OR_USERNAME,
                              child: Container(
                                child: SubmitButton(
                                  text: 'Reset Password',
                                  isSubmitting: false,
                                  formIsValid: true,
                                  handleOnSubmit: () =>
                                      _sendPasswordResetEmail(context),
                                ),
                              ),
                            ),
                            SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  child: Text('Delete Account'),
                                  onTap: () =>
                                      _displayDeleteAccountConfirmationDialog(),
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.1),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                bottomNavigationBar: BottomNavigationBar(
                  //ype: BottomNavigationBarType.shifting,
                  backgroundColor: theme.background,
                  unselectedItemColor: theme.primaryVariant.withOpacity(0.75),
                  selectedItemColor: theme.primaryVariant,
                  items: [
                    BottomNavigationBarItem(
                      title: Text('SUN'),
                      icon: Icon(Icons.wb_sunny),
                    ),
                    BottomNavigationBarItem(
                        title: Text('ACCOUNT'), icon: Icon(Icons.account_box)),
                  ],
                  onTap: (int index) {
                    if (index == 0) {
                      // sun
                      Navigator.pushNamed(context, '/dashboard');
                    } else if (index == 1) {
                      Navigator.pushNamed(context, '/account');
                    }
                  },
                ),
              ),
              onWillPop: () async {
                return await Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              });
        }

        return widget;
      },
    );
  }
}
