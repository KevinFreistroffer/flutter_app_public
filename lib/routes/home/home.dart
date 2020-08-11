import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_keto/widgets/welcome.text.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_keto/services/database.service.dart';
import 'package:flutter_keto/services/authentication.service.dart';
import 'package:flutter_keto/constants.dart';
import 'package:flutter_keto/widgets/loading_screen/LoadingScreen.dart';
import 'package:flutter_keto/globals.dart';
import 'package:flutter_keto/theme.dart';
import 'package:flutter_keto/error_dialog.dart';
import 'package:flutter_keto/wait.dart';
import 'package:flutter_keto/state/app_state.dart';
import 'package:flutter_keto/store.dart';
import 'package:flutter_keto/actions/user_actions.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Globals _globals = Globals();
  final AuthenticationService _authService = AuthenticationService();
  final DatabaseService _databaseService = DatabaseService();
  bool _fadeInTitle = false;
  bool _fadeInButton1 = false;
  bool _fadeInButton2 = false;
  bool _fadeInLogin = false;
  double sigmaX = 5;
  double sigmaY = 5;

  Map _errors = {
    'username': null,
    'form': null,
  };

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
  );

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((firebaseUser) async {
      if (firebaseUser != null) {
        // Set the UID in the store
        // store.dispatch(
        //   SetUserValuesAction(uid: firebaseUser.uid),
        // );

        final storedUser = await _databaseService.getUserWithUID(
          firebaseUser.uid,
        );

        // If a user exists in the database with the UID, then add the rest
        // of the users data in the store
        if (storedUser is DocumentSnapshot) {
          // store.dispatch(
          //   SetUserValuesAction(
          //     email: storedUser.data['email'],
          //     username: storedUser.data['username'],
          //     nickname: storedUser.data['nickname'],
          //     phoneNumber: storedUser.data['phoneNumber'],
          //     platform: storedUser.data['platform'] ?? Constants.GOOGLE,
          //   ),
          // );
        }

        Navigator.pushNamedAndRemoveUntil(
          context,
          storedUser is DocumentSnapshot ? '/dashboard' : '/create-a-nickname',
          (route) => false,
        );
      }
    }).catchError((error) {
      ErrorDialog.displayErrorDialog(context, error.toString());
    }).whenComplete(() {
      setState(() {
        _fadeInTitle = true;
        _fadeInButton1 = true;
        _fadeInButton2 = true;
        _fadeInLogin = true;
      });
    });
  }

  Future<void> _handleSignInWithGoogle() async {
    var googleResponse = await _authService.beginSignInWithGoogle();

    if (googleResponse is AuthCredential) {
      var credentialResponse =
          await _authService.signInWithCredential(googleResponse);

      if (credentialResponse is AuthResult) {
        // success
        final firebaseUser = await FirebaseAuth.instance.currentUser();

        if (firebaseUser != null) {
          final storedUser =
              await _databaseService.getUserWithUID(firebaseUser.uid);

          if (storedUser is DocumentSnapshot) {
            store.dispatch(
              SetUserValuesAction(
                uid: firebaseUser.uid,
                email: storedUser.data['email'],
                username: storedUser.data['username'],
                nickname: storedUser.data['nickname'],
                phoneNumber: storedUser.data['phoneNumber'],
                platform: storedUser.data['platform'] ?? Constants.GOOGLE,
              ),
            );
          }

          store.dispatch(
            SetUserValuesAction(
              uid: firebaseUser.uid,
              email: firebaseUser.email,
              platform: Constants.GOOGLE,
            ),
          );

          await wait(ms: 1800);

          Navigator.pushNamedAndRemoveUntil(
            context,
            storedUser != null ? '/dashboard' : '/create-a-nickname',
            (route) => false,
          );
        } else {
          throw ('getUser() is returning null after signing in with credential');
        }
      } else if (credentialResponse is String) {
        _displayErrorDialog(credentialResponse);
      }
    } else if (googleResponse is String) {
      _displayErrorDialog(googleResponse);
    }
  }

  _displayErrorDialog(
    String error, {
    bool barrierDismissible = true,
  }) {
    final AppTheme theme = Provider.of(context, listen: false);
    final LineSplitter ls = LineSplitter();
    final styles = ErrorDialogStyles.alertDialog;

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
            color: theme.background,
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
    AppTheme theme = Provider.of(context, listen: false);

    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        if (state.loadingState.isOpen) {
          return LoadingScreen(title: '', showIcon: true);
        } else {
          return MaterialApp(
            builder: (BuildContext context, widget) {
              return Scaffold(
                key: _globals.scaffoldKey,
                appBar: null,
                body: OrientationBuilder(
                  builder: (BuildContext context, Orientation orientation) {
                    return Container(
                      //padding: EdgeInsets.all(16),
                      width: size.width,
                      height: size.height,
                      // constraints: BoxConstraints(minHeight: 200),
                      // color: Colors.white,
                      //color: Colors.black,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/1.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),

                      child: SingleChildScrollView(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                width: size.width,
                                height: size.height,
                                color: Colors.blue.withOpacity(0.2),
                                child: Text(''),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  height: orientation == Orientation.portrait
                                      ? (size.height * .5) -
                                          (Constants.STATUS_BAR_HEIGHT * 3)
                                      : 100,
                                  margin: EdgeInsets.only(
                                    top: Constants.APP_BAR_HEIGHT +
                                        Constants.STATUS_BAR_HEIGHT,
                                  ),

                                  child: Column(
                                    children: [
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          color: Colors.yellow,
                                                          width: 3,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          'Welcome To',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .luckiestGuy(
                                                            fontSize:
                                                                size.width *
                                                                    .05,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            letterSpacing: 4.0,
                                                            color:
                                                                theme.primary,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16),
                                                        Text(
                                                          'Pi Solar',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .luckiestGuy(
                                                            fontSize:
                                                                size.width * .1,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            letterSpacing: 4.0,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          'Tracker',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .luckiestGuy(
                                                            fontSize:
                                                                size.width * .1,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            letterSpacing: 4.0,
                                                            color:
                                                                theme.primary,
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // color: Colors.red,
                                ),
                                //SizedBox(height: 32),
                                /**
                             * ideally it is split 50 50 or something.
                             * ideally there's a minimum height of the container
                             * ideally the title height is say 30% of the total 
                             * ideally the links are height of 70% column mainAxisAlignment.bottom
                             */
                                Container(
                                  height: orientation == Orientation.portrait
                                      ? size.height * .5
                                      : 300,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      AnimatedOpacity(
                                        duration: Duration(milliseconds: 715),
                                        opacity: _fadeInButton1 ? 1.0 : 0.0,
                                        child: GestureDetector(
                                          onTap: () => Navigator.pushNamed(
                                              context, '/signup'),
                                          child: Text(
                                            'SIGN UP FOR FREE',
                                            style: TextStyle(
                                              fontSize: orientation ==
                                                      Orientation.portrait
                                                  ? size.width * .05
                                                  : 24,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      AnimatedOpacity(
                                        duration: Duration(milliseconds: 715),
                                        opacity: _fadeInButton2 ? 1.0 : 0.0,
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: GestureDetector(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Image(
                                                      width: orientation ==
                                                              Orientation
                                                                  .portrait
                                                          ? size.width * .045
                                                          : 24,
                                                      height: orientation ==
                                                              Orientation
                                                                  .portrait
                                                          ? size.width * .045
                                                          : 24,
                                                      image: AssetImage(
                                                        'assets/google_logo.png',
                                                      ),
                                                    ),
                                                    SizedBox(width: 16),
                                                    Text(
                                                      'CONTINUE WITH GOOGLE',
                                                      style: TextStyle(
                                                        fontSize: orientation ==
                                                                Orientation
                                                                    .portrait
                                                            ? size.width * .05
                                                            : 24,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onTap: () {
                                                  _handleSignInWithGoogle();
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 24),
                                      AnimatedOpacity(
                                        duration: Duration(milliseconds: 500),
                                        opacity: _fadeInLogin ? 1.0 : 0.0,
                                        child: Container(
                                          width: size.width,
                                          constraints: BoxConstraints(
                                            maxWidth: 290,
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.only(
                                              top: 0,
                                            ),
                                            child: GestureDetector(
                                              onTap: () => Navigator.pushNamed(
                                                context,
                                                '/login',
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    'LOGIN',
                                                    style: TextStyle(
                                                      //fontSize: 18,
                                                      fontSize: orientation ==
                                                              Orientation
                                                                  .portrait
                                                          ? size.width * .045
                                                          : 24,

                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}
