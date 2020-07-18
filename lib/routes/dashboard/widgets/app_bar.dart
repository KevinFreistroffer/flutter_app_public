import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/loading.service.dart';
import '../../../services/authentication.service.dart';
import '../../../constants.dart';
import '../../../theme.dart';
import '../../../state/user_model.dart';
import '../../../wait.dart';

class CustomAppBar extends StatelessWidget {
  final AuthenticationService _authService = AuthenticationService();
  final LoadingService _loadingService = LoadingService();

  CustomAppBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppTheme theme = Provider.of(context, listen: false);

    return Consumer<UserModel>(
      builder: (context, userState, child) {
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
                          _loadingService.add(isOpen: true, isSigningOut: true);
                          userState.emptyAllValues();
                          _authService.signOut();
                          await wait(s: 2);
                          _loadingService.add(isOpen: false);
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
      },
    );
  }
}
