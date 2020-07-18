import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../services/authentication.service.dart';
import '../../services/loading.service.dart';
import '../../services/storage.service.dart';
import '../../constants.dart';
import '../../theme.dart';
import '../../widgets/submit_button.dart';
import '../../widgets/loading_screen/LoadingScreen.dart';
import '../../state/user_model.dart';

class SignUpFromIdentityProvider extends StatefulWidget {
  SignUpFromIdentityProvider({Key key}) : super(key: key);

  @override
  _SignUpFromIdentityProviderState createState() =>
      _SignUpFromIdentityProviderState();
}

class _SignUpFromIdentityProviderState
    extends State<SignUpFromIdentityProvider> {
  final AuthenticationService _authService = AuthenticationService();
  final StorageService _storageService = StorageService();
  final LoadingService _loadingService = LoadingService();
  UserModel _userModel;
  PageController _pageController;
  bool _isSubmitting = false;
  Map<String, dynamic> _formValues = {
    'email': '',
    'username': '',
    'password': '',
    'confirmPassword': ''
  };
  Map<String, dynamic> _errors = {
    'email': null,
    'username': null,
    'password': null,
    'confirmPassword': null
  };

  @override
  void initState() {
    super.initState();
    _pageController = new PageController(initialPage: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userModel = Provider.of<UserModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Provider.of<AppTheme>(context);
    final Size size = MediaQuery.of(context).size;
    Widget widget;

    return Consumer<UserModel>(
      builder: (context, user, child) {
        StreamBuilder(
          stream: _loadingService.controller.stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data['isOpen']) {
                widget = LoadingScreen();
              } else {
                widget = Scaffold(
                  appBar: null,
                  body: Container(
                    height: size.height,
                    width: size.width,
                    color: theme.background,
                    padding: EdgeInsets.fromLTRB(
                      size.width * .1,
                      size.width * .125,
                      size.width * .1,
                      size.width * .125,
                    ),
                    child: PageView(
                      controller: _pageController,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 32),
                            Visibility(
                              visible: snapshot.data == Constants.GOOGLE,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    color: Colors.black12,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Your email is already set:',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: theme.onBackground),
                                        ),
                                        SizedBox(height: 8),
                                        Text('${user.email}',
                                            style: TextStyle(fontSize: 20)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 40),
                                  Text('Create a username',
                                      style: TextStyle(fontSize: 30)),
                                  SizedBox(height: 8),
                                  TextFormField(
                                    decoration:
                                        InputDecoration(hintText: 'Username'),
                                    onChanged: (v) {},
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: snapshot.data == Constants.PHONE,
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    'Add an email',
                                    style: TextStyle(color: theme.onBackground),
                                  ),
                                  TextFormField(
                                    onChanged: (value) {},
                                  ),
                                  Text('Username'),
                                  TextFormField(
                                    onChanged: (v) {},
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            SubmitButton(
                              text: 'Next',
                              formIsValid: snapshot.data == Constants.GOOGLE
                                  ? (_errors['username'] == null ? true : false)
                                  : _errors['email'] == null &&
                                          _errors['username'] == null
                                      ? true
                                      : false,
                              isSubmitting: _isSubmitting,
                              handleOnSubmit: () {
                                setState(() => _isSubmitting = !_isSubmitting);
                                return _pageController.nextPage(
                                  duration: Duration(milliseconds: 215),
                                  curve: Curves.elasticIn,
                                );
                              },
                            ),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                // widget.dashboardPageController.previousPage(
                                //   duration: Duration(milliseconds: 215),
                                //   curve: Curves.elasticIn,
                                // );
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/dashboard',
                                  (route) => false,
                                );
                              },
                              child: Text(
                                'Cancel creating an account',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: theme.onBackground,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: 32),
                              Text('Create a password'),
                              Text('Confirm the password'),
                              SubmitButton(
                                text: 'Next',
                                formIsValid: _errors['password'] == null &&
                                        _errors['confirmPassword'] == null
                                    ? true
                                    : false,
                                isSubmitting: _isSubmitting,
                                handleOnSubmit: () {},
                              ),
                              RaisedButton(
                                child: Text('Go Back'),
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: Duration(milliseconds: 215),
                                    curve: Curves.elasticIn,
                                  );
                                },
                              ),
                              SizedBox(height: 8),
                              GestureDetector(
                                child: Text('Cancel creating an account'),
                                onTap: () {
                                  // widget.dashboardPageController.previousPage(
                                  //   duration: Duration(milliseconds: 215),
                                  //   curve: Curves.elasticIn,
                                  // );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            } else {
              widget = LoadingScreen();
            }

            return widget;
          },
        );
      },
    );
  }
}
