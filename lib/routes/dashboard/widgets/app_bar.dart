import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_keto/actions/loading_actions.dart';
import 'package:flutter_keto/actions/user_actions.dart';
import 'package:flutter_keto/state/app_state.dart';
import 'package:flutter_keto/store.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:provider/provider.dart';
import '../../../services/authentication.service.dart';
import '../../../constants.dart';
import '../../../theme.dart';
import '../../../wait.dart';

class CustomAppBar extends StatelessWidget {
  final AuthenticationService _authService = AuthenticationService();

  CustomAppBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppTheme theme = Provider.of(context, listen: false);

    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: size.width,
                  height: Constants.APP_BAR_HEIGHT + 24,
                  padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 16),
                        child: Text(
                          Constants.APP_NAME,
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(top: 16),
                        child: PopupMenuButton(
                          color: theme.surface,
                          icon: Icon(
                            Icons.more_vert,
                            color: theme.onBackground,
                          ),
                          onSelected: (result) async {
                            store.dispatch(
                              SetLoadingValuesAction(
                                  isOpen: true,
                                  showIcon: state.loadingState.showIcon,
                                  title: state.loadingState.title,
                                  text: state.loadingState.text),
                            );
                            store.dispatch(EmptyUserValuesAction());
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
                          },
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuEntry>[
                              // Should be a for loop

                              // for (final item in menuItems)
                              //   PopupMenuItem(
                              //     value: item.value,
                              //     child: Text(
                              //       item.text,
                              //       style: TextStyle(
                              //           color:
                              //               theme.primary),
                              //     ),
                              //   ),

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
                  ),
                ),
                /**
                                       * So a row with the SunScript and the menu trigger
                                       * it need sto be positioned at the top
                                       * stack needs to take up 100% of the screen height
                                       * the middle row needs to take up 100% of the screen height - top row's height
                                       * or
                                       */
              ],
            ),
          );
        });
  }
}
