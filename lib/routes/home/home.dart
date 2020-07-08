import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../services/database.service.dart';
import '../../services/authentication.service.dart';
import '../../services/loading.service.dart';
import './styles.dart';
import '../../constants.dart';
import '../../widgets/loading_screen/LoadingScreen.dart';
import '../../globals.dart';
import '../../theme.dart';
import '../../error_dialog.dart';
import '../../wait.dart';
import '../../state/user_model.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Globals _globals = Globals();
  final AuthenticationService _authService = AuthenticationService();
  final DatabaseService _databaseService = DatabaseService();
  final LoadingService _loadingService = new LoadingService();
  UserModel _userModel;
  bool _fadeInTitle = false;
  bool _fadeInButton1 = false;
  bool _fadeInButton2 = false;
  bool _fadeInLogin = false;

  Map _errors = {
    'username': null,
    'form': null,
  };

  @override
  void initState() {
    super.initState();
    _userModel = Provider.of<UserModel>(context, listen: false);
    // _loadingService.add(isOpen: true);

    FirebaseAuth.instance.currentUser().then((firebaseUser) async {
      if (firebaseUser != null) {
        _userModel.set(uid: firebaseUser.uid);

        final storedUser =
            await _databaseService.getUserWithUID(firebaseUser.uid);

        if (storedUser is DocumentSnapshot) {
          _userModel.set(
            email: storedUser.data['email'],
            username: storedUser.data['username'],
            nickname: storedUser.data['nickname'],
            phoneNumber: storedUser.data['phoneNumber'],
            platform: storedUser.data['platform'] ?? Constants.GOOGLE,
          );
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
      _loadingService.add(isOpen: false);

      setState(() {
        _fadeInTitle = true;
        _fadeInButton1 = true;
        _fadeInButton2 = true;
        _fadeInLogin = true;
      });
    });
  }

  Future<void> _handleSignInWithGoogle() async {
    AuthCredential authCredential = await _authService.signInWithGoogle();

    try {
      await _authService.signInWithCredential(authCredential);
      final firebaseUser = await FirebaseAuth.instance.currentUser();

      if (firebaseUser != null) {
        final storedUser =
            await _databaseService.getUserWithUID(firebaseUser.uid);

        if (storedUser is DocumentSnapshot) {
          _userModel.set(
            uid: firebaseUser.uid,
            email: storedUser.data['email'],
            username: storedUser.data['username'],
            nickname: storedUser.data['nickname'],
            phoneNumber: storedUser.data['phoneNumber'],
            platform: storedUser.data['platform'] ?? Constants.GOOGLE,
          );
        }

        _userModel.set(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          platform: Constants.GOOGLE,
        );

        _loadingService.add(isOpen: true);
        await wait(ms: 1800);

        Navigator.pushNamedAndRemoveUntil(
          context,
          storedUser != null ? '/dashboard' : '/create-a-nickname',
          (route) => false,
        );
      } else {
        throw ('getUser() is returning null after signing in with credential');
      }
    } catch (error) {
      ErrorDialog.displayErrorDialog(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    AppTheme theme = Provider.of(context);

    return MaterialApp(
      builder: (BuildContext context, widget) {
        return StreamBuilder(
          stream: _loadingService.controller.stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            Widget _widget;
            if (snapshot.hasData && snapshot.data['isOpen']) {
              _widget = LoadingScreen(
                title: snapshot.data['title'],
                text: snapshot.data['text'],
                showIcon: snapshot.data['showIcon'],
                size: snapshot.data['size'],
                showSuccessIcon: snapshot.data['showSuccessIcon'],
              );
            } else {
              _widget = Scaffold(
                key: _globals.scaffoldKey,
                appBar: null,
                body: OrientationBuilder(
                  builder: (BuildContext context, Orientation orientation) {
                    return Container(
                      width: size.width,
                      height: size.height,
                      color: theme.background,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  height: orientation == Orientation.portrait
                                      ? size.height * .5
                                      : 180,
                                  width: size.width * .9,
                                  child: AnimatedOpacity(
                                    duration: Duration(milliseconds: 607),
                                    opacity: _fadeInTitle ? 1.0 : 0.0,
                                    child: Center(
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(height: size.height * .1),
                                          // Icon(
                                          //   Icons.account_circle,
                                          //   size: 150.0,
                                          //   color: theme.onBackground
                                          //       .withOpacity(0.25),
                                          // ),
                                          Container(
                                            padding: EdgeInsets.fromLTRB(
                                                5, 2.5, 5, 2.5),
                                            decoration: BoxDecoration(
                                              color: theme.secondary
                                                  .withOpacity(0.05),
                                              border: Border.all(
                                                color: theme.onBackground
                                                    .withOpacity(0.25),
                                                width: 2,
                                              ),
                                            ),
                                            child: Text(
                                              Constants.APP_NAME,
                                              style: TextStyle(
                                                fontSize: 30.0,
                                                color: theme.onBackground
                                                    .withOpacity(0.25),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
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
                                        child: Container(
                                          width: size.width,
                                          constraints:
                                              BoxConstraints(maxWidth: 290),
                                          child: Theme(
                                            data: theme.themeData,
                                            child: RaisedButton(
                                              onPressed: () =>
                                                  Navigator.pushNamed(
                                                      context, '/signup'),
                                              child: Text(
                                                'SIGN UP FOR FREE',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: theme.background
                                                      .withOpacity(0.65),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 18),
                                      AnimatedOpacity(
                                        duration: Duration(milliseconds: 715),
                                        opacity: _fadeInButton2 ? 1.0 : 0.0,
                                        child: Container(
                                          width: size.width,
                                          constraints: BoxConstraints(
                                            maxWidth: 290,
                                          ),
                                          child: RaisedButton.icon(
                                            padding: EdgeInsets.all(18),
                                            color: theme.background,
                                            icon: Container(
                                              margin: EdgeInsets.only(right: 5),
                                              child: Image(
                                                width: 20,
                                                height: 20,
                                                image: AssetImage(
                                                  'assets/images/google_logo.png',
                                                ),
                                              ),
                                            ),
                                            label: Center(
                                              child: Text(
                                                'CONTINUE WITH GOOGLE',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: theme.onBackground,
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              _handleSignInWithGoogle();
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
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
                                                      fontSize: 18,
                                                      color: theme.onBackground,
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
                                SizedBox(height: size.height * .05),
                              ],
                            ),
                          ],
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
