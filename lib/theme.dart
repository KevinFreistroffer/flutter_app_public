import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  Color primary;
  Color primaryVariant;
  Color secondary;
  Color secondaryVariant;
  Color background;
  Color surface;
  Color accent1;
  Color error;
  Color onPrimary;
  Color onPrimaryVariant;
  Color onSecondary;
  Color onSecondaryVariant;
  Color onBackground;
  Color onSurface;
  Color onError;
  Color loadingIconColor;
  bool isDark;
  BuildContext context;

  AppTheme({@required this.isDark, @required this.context});

  ThemeData get themeData {
    // TextTheme textTheme =
    //     GoogleFonts.openSansTextTheme(Theme.of(context).textTheme);
    TextTheme textTheme =
        GoogleFonts.notoSansTextTheme(Theme.of(context).textTheme);
    ColorScheme colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primary,
      primaryVariant: primaryVariant,
      secondary: secondary,
      secondaryVariant: secondaryVariant,
      background: background,
      surface: surface,
      error: error,
      onBackground: onBackground,
      onSurface: onSurface,
      onError: onError,
      onPrimary: onPrimary,
      onSecondary: onSecondary,
    );

    var t = ThemeData.from(
      textTheme: textTheme,
      colorScheme: colorScheme,
    ).copyWith(
      buttonTheme: ButtonThemeData(
        buttonColor: secondary,
        textTheme: ButtonTextTheme.normal,
        disabledColor: Colors.white,
        //buttonColor: Color.fromRGBO(193, 92, 55, 1),
        padding: EdgeInsets.fromLTRB(0, 17, 0, 17),
        colorScheme: Theme.of(context).colorScheme.copyWith(
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onBackground: Colors.white,
              onSurface: Colors.white,
              secondary: Colors.white,
            ),
      ),
      cursorColor: primaryVariant,
      appBarTheme: AppBarTheme(
        textTheme: TextTheme(
          headline6: GoogleFonts.notoSans(
            textStyle: TextStyle(
              fontSize: 20.0,
              color: onPrimary.withOpacity(0.95),
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: onPrimary.withOpacity(0.45),
        ),
      ),
      highlightColor: accent1,
      toggleableActiveColor: accent1,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 5.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: onBackground.withOpacity(0.25),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: onBackground.withOpacity(0.65),
            width: 2.0,
          ),
        ),
        hintStyle: TextStyle(
          color: onBackground.withOpacity(0.5),
        ),
        filled: true,
        fillColor: Colors.transparent,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelStyle: TextStyle(
          color: onBackground,
        ),
        errorStyle: TextStyle(
          color: error,
          fontWeight: FontWeight.bold,
          fontSize: 15,
          letterSpacing: 0.2,
          // backgroundColor: Colors.white.withOpacity(0.2),
        ),
        errorMaxLines: 3,
        // border: new UnderlineInputBorder(
        //   borderSide: BorderSide(color: onBackground),
        // ),
      ),
    );

    return t;
  }
}
