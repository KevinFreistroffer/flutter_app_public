import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_redux/flutter_redux.dart';
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
import '../../models/app_state.dart';
import '../../models/loading_state.dart';
import '../../store.dart';
import '../../actions/loading_actions.dart';

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
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      print('googleSignIn.onCurrentUserChanged account $account');
    }).onError((error) {
      print('googleSignIn.onCurrentUserChanged error $error');
    });
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
      // _loadingService.add(isOpen: false);

      setState(() {
        _fadeInTitle = true;
        _fadeInButton1 = true;
        _fadeInButton2 = true;
        _fadeInLogin = true;
      });
    });
  }

  @override
  void dispose() {
    //_loadingService.add(isOpen: false);
    super.dispose();
  }

  Future<void> _handleSignInWithGoogle() async {
    //_loadingService.add(isOpen: true);
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
    //_loadingService.add(isOpen: false);
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
    AppTheme theme = Provider.of(context, listen: false);
    var store = StoreProvider.of<AppState>(context);

    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        print('Home state ${state.loadingState}');

        if (state.loadingState.isOpen) {
          return Text(
            'abcdefg',
            style: TextStyle(
              color: Colors.red,
            ),
          );
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
                      constraints: BoxConstraints(minHeight: 200),
                      color: theme.background,
                      child: SingleChildScrollView(
                        child: Stack(
                          children: <Widget>[
                            // Positioned.fill(
                            //   child: Image(
                            //     image: AssetImage('assets/bedroom.jpg'),
                            //   ),
                            // ),
                            Positioned.fill(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 5,
                                  sigmaY: 5,
                                ),
                                child: Container(
                                  color: Colors.blue.withOpacity(0.7),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(
                                  height: size.height * .3,
                                  //padding: EdgeInsets.all(20),
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
                                          Text(Constants.APP_NAME,
                                              style: GoogleFonts.notoSans(
                                                  fontSize: size.width * .075,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme.onBackground)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 32),
                                /**
                             * ideally it is split 50 50 or something.
                             * ideally there's a minimum height of the container
                             * ideally the title height is say 30% of the total 
                             * ideally the links are height of 70% column mainAxisAlignment.bottom
                             */
                                Container(
                                  height: orientation == Orientation.portrait
                                      ? size.height * .7
                                      : 300,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      AnimatedOpacity(
                                        duration: Duration(milliseconds: 715),
                                        opacity: _fadeInButton1 ? 1.0 : 0.0,
                                        child: RaisedButton(
                                          color: Colors.transparent,
                                          onPressed: () => Navigator.pushNamed(
                                              context, '/signup'),
                                          child: Text(
                                            'SIGN UP FOR FREE',
                                            style: TextStyle(
                                              fontSize: orientation ==
                                                      Orientation.portrait
                                                  ? size.width * .045
                                                  : 24,
                                              fontWeight: FontWeight.w300,
                                              color: theme.onBackground,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      AnimatedOpacity(
                                        duration: Duration(milliseconds: 715),
                                        opacity: _fadeInButton2 ? 1.0 : 0.0,
                                        child: Container(
                                          width: size.width,
                                          color: Colors.transparent,
                                          child: RaisedButton.icon(
                                            padding: EdgeInsets.all(18),
                                            color: Colors.black.withOpacity(0),
                                            icon: Container(
                                              margin: EdgeInsets.only(right: 5),
                                              child: Image(
                                                width: orientation ==
                                                        Orientation.portrait
                                                    ? size.width * .045
                                                    : 24,
                                                height: orientation ==
                                                        Orientation.portrait
                                                    ? size.width * .045
                                                    : 24,
                                                image: AssetImage(
                                                  'assets/google_logo.png',
                                                ),
                                              ),
                                            ),
                                            label: Center(
                                              child: Text(
                                                'CONTINUE WITH GOOGLE',
                                                style: TextStyle(
                                                  fontSize: orientation ==
                                                          Orientation.portrait
                                                      ? size.width * .05
                                                      : 24,
                                                  fontWeight: FontWeight.w300,
                                                  color: theme.onBackground,
                                                ),
                                              ),
                                            ),
                                            onPressed: () {
                                              print(
                                                  'Home Sign In With Google onPressed()');
                                              _handleSignInWithGoogle();
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
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
                                                      fontWeight:
                                                          FontWeight.w300,
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
