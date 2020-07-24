import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/loading.service.dart';
import '../../services/storage.service.dart';
import '../../services/authentication.service.dart';
import '../../constants.dart';
import '../../wait.dart';
import '../../theme.dart';
import '../../state/user_model.dart';

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
  final LoadingService _loadingService = LoadingService();
  final List menuItems = [];
  UserModel _userModel;
  String username;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _userModel = Provider.of<UserModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Provider.of<AppTheme>(context);
    final UserModel userModel = Provider.of<UserModel>(context);

    return Consumer<UserModel>(
      builder: (context, value, child) {
        return AppBar(
          backgroundColor: Colors.white,
          //backgroundColor: widget.backgroundColor,
          automaticallyImplyLeading: widget.automaticallyImplyLeading,
          title: Text(
            widget.title,
            style: GoogleFonts.notoSans(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
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
                      _loadingService.add(isOpen: true, isSigningOut: true);
                      userModel.emptyAllValues();
                      _authService.signOut();
                      await wait(s: 2);
                      _loadingService.add(isOpen: false);
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
