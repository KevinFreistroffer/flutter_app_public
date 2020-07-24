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

class NotSignedInAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool automaticallyImplyLeading;
  final Color backgroundColor;
  final double elevation;

  NotSignedInAppBar({
    Key key,
    @required this.title,
    this.automaticallyImplyLeading = false,
    this.backgroundColor,
    this.elevation,
  }) : super(key: key);

  @override
  _NotSignedInAppBarState createState() => _NotSignedInAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(Constants.APP_BAR_HEIGHT);
}

class _NotSignedInAppBarState extends State<NotSignedInAppBar> {
  final List menuItems = [];

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Provider.of<AppTheme>(context);

    AppBar(
      backgroundColor: theme.primary,
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      title: Text(widget.title, style: GoogleFonts.notoSans()),
      elevation: widget.elevation ?? null,
      actions: null,
    );
  }
}
