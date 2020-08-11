import 'package:flutter/material.dart';
import 'package:flutter_keto/actions/loading_actions.dart';
import 'package:flutter_keto/actions/raspberry_pi_actions.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_keto/services/storage.service.dart';
import 'package:flutter_keto/services/authentication.service.dart';
import 'package:flutter_keto/constants.dart';
import 'package:flutter_keto/wait.dart';
import 'package:flutter_keto/theme.dart';
import 'package:flutter_keto/state/app_state.dart';
import 'package:flutter_keto/state/user_state.dart';
import 'package:flutter_keto/actions/user_actions.dart';
import 'package:flutter_keto/store.dart';

class SignedInAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool automaticallyImplyLeading;
  final Color backgroundColor;
  final double elevation;
  final double height;
  PreferredSize bottom;

  SignedInAppBar({
    Key key,
    @required this.title,
    this.automaticallyImplyLeading = false,
    this.backgroundColor,
    this.elevation,
    this.height = Constants.APP_BAR_HEIGHT,
    this.bottom,
  }) : super(key: key);

  @override
  _SignedInAppBarState createState() => _SignedInAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(Constants.APP_BAR_HEIGHT);
}

class _SignedInAppBarState extends State<SignedInAppBar> {
  static const ACCOUNT = 'My Account';

  final AuthenticationService _authService = AuthenticationService();
  final StorageService _storageService = StorageService();
  final List menuItems = [];
  String username;

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Provider.of<AppTheme>(context);

    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        return AppBar(
          backgroundColor: Colors.white,
          //backgroundColor: widget.backgroundColor,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          automaticallyImplyLeading: widget.automaticallyImplyLeading,
          title: Text(
            widget.title,
            style: Theme.of(context).textTheme.headline6,
          ),
          bottom: widget.bottom ?? null,
          elevation: widget.elevation ?? null,
          actions: <Widget>[
            Container(
              child: PopupMenuButton(
                color: theme.surface,
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.black,
                ),
                onSelected: (result) async {
                  switch (result) {
                    case ACCOUNT:
                      Navigator.pushNamed(context, '/account');
                      break;
                    case Constants.SIGN_OUT:
                      store.dispatch(
                        SetLoadingValuesAction(
                          isOpen: true,
                          showIcon: state.loadingState.showIcon,
                          title: state.loadingState.title,
                          text: state.loadingState.text,
                        ),
                      );
                      store.dispatch(EmptyUserValuesAction());
                      store.dispatch(
                        SetSSHStatusAction(
                          sshStatus: Constants.SSH_DISCONNECTED,
                        ),
                      );
                      store.dispatch(
                        SetScriptStatusAction(scriptRunning: false),
                      );
                      store.dispatch(
                        SetAutoStartValuesAction(
                          autoStart: false,
                          autoStartTime: null,
                          autoStartAtSunrise: false,
                          autoStartTimeAsString: '',
                        ),
                      );
                      _authService.signOut();
                      await wait(s: 2);
                      store.dispatch(
                        SetLoadingValuesAction(
                          isOpen: false,
                          showIcon: state.loadingState.showIcon,
                          title: state.loadingState.title,
                          text: state.loadingState.text,
                        ),
                      );
                      Navigator.pushNamed(context, '/');
                      break;

                    default:
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry>[
                    // Should be a for loop

                    for (final item in menuItems)
                      PopupMenuItem(
                        value: item.value,
                        child: Text(
                          item.text,
                          style: TextStyle(color: theme.primary),
                        ),
                      ),

                    PopupMenuItem(
                      height: 50,
                      value: Constants.SIGN_OUT,
                      child: Text('SIGN OUT'),
                      textStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ];
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
