import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_keto/state/app_state.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';
import '../../services/authentication.service.dart';
import '../../services/storage.service.dart';
import '../../constants.dart';
import '../../theme.dart';
import '../../widgets/submit_button.dart';
import '../../widgets/loading_screen/LoadingScreen.dart';

class SignUpFromIdentityProvider extends StatefulWidget {
  SignUpFromIdentityProvider({Key key}) : super(key: key);

  @override
  _SignUpFromIdentityProviderState createState() =>
      _SignUpFromIdentityProviderState();
}

class _SignUpFromIdentityProviderState
    extends State<SignUpFromIdentityProvider> {
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
  Widget build(BuildContext context) {
    final AppTheme theme = Provider.of<AppTheme>(context);
    final Size size = MediaQuery.of(context).size;
    Widget widget;

    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          if (state.loadingState.isOpen) {
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
                          visible: state.userState.platform == Constants.GOOGLE,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                color: Colors.black12,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Your email is already set:',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: theme.onBackground),
                                    ),
                                    SizedBox(height: 8),
                                    Text('${state.userState.email}',
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
                          visible: state.userState.platform == Constants.PHONE,
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
                          formIsValid:
                              state.userState.platform == Constants.GOOGLE
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

          return widget;
        });
  }
}
