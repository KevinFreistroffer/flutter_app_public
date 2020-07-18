import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/new_user.dart';
import '../../services/storage.service.dart';
import '../../services/authentication.service.dart';
import '../../services/database.service.dart';
import '../../services/loading.service.dart';
import '../../constants.dart';
import '../../theme.dart';
import '../../widgets/submit_button.dart';
import '../../widgets/loading_screen/LoadingScreen.dart';
import '../../widgets/AppBars/signed_in_app_bar.dart';
import '../../error_dialog.dart';
import '../../wait.dart';
import '../../styles/ErrorDialog.dart';
import '../../state/user_model.dart';

class CreateANickname extends StatefulWidget {
  CreateANickname({Key key}) : super(key: key);

  @override
  _CreateANicknameState createState() => _CreateANicknameState();
}

class _CreateANicknameState extends State<CreateANickname> {
  final LoadingService _loadingService = LoadingService();
  final AuthenticationService _authService = AuthenticationService();
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  UserModel _userModel;
  PageController _pageController;
  int _currentPage = 0;
  String _nickname = '';
  dynamic _error = null;
  double _createANicknameOpacity = 0;
  double _successMsg1Opacity = 0;
  double _successMsg2Opacity = 0;
  bool _submitting = false;
  bool _createANicknameIsVisible = false;
  bool _successMessageIsVisible = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, keepPage: true);
    _currentPage = 0;

    setState(() => _createANicknameIsVisible = true);
    wait(s: 1).then((_) => setState(() => _createANicknameOpacity = 1));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userModel = Provider.of<UserModel>(context, listen: false);
  }

  void _handleNicknameValueOnChange(String value) {
    setState(() {
      _nickname = value.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
      _error = value.isNotEmpty ? null : _error;
    });
  }

  void _validateNickname() {
    setState(() {
      _error = _nickname.isEmpty ? Constants.ERROR_NICKNAME_REQUIRED : null;
    });
  }

  Future<void> _submitForm() async {
    setState(() => _submitting = true);
    _validateNickname();

    if (_error == null) {
      final platform = _userModel.platform;
      final FirebaseUser firebaseUser = await _authService.getUser();

      final response =
          await _databaseService.createUserWithAdditionalProperties(
        NewUser(
          email: platform == Constants.GOOGLE ? firebaseUser.email : '',
          username: '',
          phoneNumber:
              platform == Constants.GOOGLE ? '' : firebaseUser.phoneNumber,
          uid: firebaseUser.uid,
          nickname: _nickname,
          platform: platform,
        ),
      );

      if (response is DocumentReference) {
        await _storageService.set('username', 'String', _nickname);
        _userModel.set(nickname: _nickname);
      } else if (response is String) {
        ErrorDialog.displayErrorDialog(context, response.toString());
      }

      setState(() => _createANicknameOpacity = 0);
      await wait(ms: 500);
      setState(() {
        _createANicknameIsVisible = false;
        _successMessageIsVisible = true;
      });
      await wait(ms: 500);
      setState(() => _successMsg1Opacity = 1);
      await wait(ms: 2500);
      setState(() => _successMsg1Opacity = 0);
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (route) => false,
      );
    }

    setState(() => _submitting = false);
  }

  // Future<void> _handleCreateAnAccountAnswer(String answer) async {
  //   setState(() => _successMsg1Opacity = 0);
  //   await wait(ms: 500).then(
  //     (_) => setState(() => _createAnAccountIsVisible = false),
  //   );
  //   await wait(ms: 500);
  //   _loadingService.add(isOpen: true);
  //   await wait(ms: 1500);
  //   Navigator.pushNamedAndRemoveUntil(
  //     context,
  //     answer == 'yes' ? '/signup-from-identity-provider' : '/dashboard',
  //     (route) => false,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppTheme theme = Provider.of<AppTheme>(context);

    return StreamBuilder(
      stream: _loadingService.controller.stream,
      builder: (context, snapshot) {
        dynamic _widget;

        if (snapshot.hasData && snapshot.data['isOpen']) {
          // if nicknameCreated = true
          // widget = LoadingScreen(customIcon: SpinKitRing(color: theme.primary, size: 50.0));
          // else
          _widget = LoadingScreen(
            customIcon: SpinKitRing(
              color: theme.secondary,
              size: 25.0,
            ),
          );
        } else {
          _widget = Scaffold(
            appBar: SignedInAppBar(
              title: Constants.APP_NAME,
            ),
            body: SingleChildScrollView(
              child: Container(
                width: size.width,
                height: _createANicknameIsVisible
                    ? size.height - Constants.APP_BAR_HEIGHT
                    : size.height - (Constants.APP_BAR_HEIGHT + 64.75),
                padding: EdgeInsets.fromLTRB(
                  size.width * .12,
                  0,
                  size.width * .12,
                  0,
                ),
                color: theme.background,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Visibility(
                      visible: _createANicknameIsVisible,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity: _createANicknameOpacity,
                        child: SingleChildScrollView(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Hi, and welcome.',
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: theme.onBackground,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Let\s start by adding a nickname',
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: theme.onBackground,
                                  ),
                                ),
                                SizedBox(height: 16),
                                new Theme(
                                  data: theme.themeData,
                                  child: TextFormField(
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'My nickname',
                                      errorText: _error,
                                    ),
                                    onChanged: _handleNicknameValueOnChange,
                                  ),
                                ),
                                SizedBox(height: 32),
                                SubmitButton(
                                  text: 'Next',
                                  formIsValid: _error == null,
                                  isSubmitting: _submitting,
                                  handleOnSubmit: _submitForm,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _successMessageIsVisible,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity: _successMsg1Opacity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'All set',
                              style: TextStyle(fontSize: 50.0),
                            ),
                            SizedBox(height: 16),
                            Text(
                              _nickname,
                              style: TextStyle(fontSize: 50.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return _widget;
      },
    );
  }
}
