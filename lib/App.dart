import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'routes/home/home.dart';
import 'routes/login/login.dart';
import 'routes/signup/signup.dart';
import 'routes/sign_up_from_identity_provider/sign_up_from_identity_provider.dart';
//import 'routes/make_a_meal/index.dart';
import 'routes/dashboard/dashboard.dart';
import 'routes/create_a_nickname/create_a_nickname.dart';
import 'routes/account/account.dart';
import 'routes/enter_phone_number/enter_phone_number.dart';
import 'routes/enter_sms_code/enter_sms_code.dart';
import 'routes/animated_screen/animated_screen.dart';
import 'routes/password_reset/password_reset.dart';
import 'routes/verify_phone/verify_phone.dart';
import 'routes/auto_start/auto_start.dart';
import './state/app_state.dart';
import './theme.dart';
import 'package:flutter_keto/route_observer.dart';

class App extends StatelessWidget {
  final String initialRoute;
  final Store store;
  App(this.initialRoute, this.store);

  @override
  Widget build(BuildContext context) {
    AppTheme appTheme = AppTheme(
      isDark: false,
      context: context,
    )
      ..primary = Colors.white
      // ..primary = Color.fromRGBO(33, 150, 243, 1)
      //..primary = Color.fromRGBO(53, 98, 17, 1)
      ..primaryVariant = Colors.black
      ..onPrimaryVariant = Colors.white
      //..primaryVariant = Color.fromRGBO(0, 13, 22, 1)
      // ..secondary = Color.fromRGBO(46, 189, 79, 1)
      ..secondary = Color.fromRGBO(61, 124, 125, 1)
      // ..secondary = Color.fromRGBO(242, 232, 128, 1)
      ..secondaryVariant = Color.fromRGBO(13, 12, 29, 1)
      ..accent1 = Color.fromRGBO(164, 96, 75, 1)
      //..accent1 = Color.fromRGBO(12, 12, 29, 1)
      ..background = Colors.white
      //..background = Color.fromRGBO(108, 143, 50, 1)
      //..bg1 = Color.fromRGBO(82, 95, 103, 1)
      ..surface = Colors.white
      ..error = Colors.red.shade400
      ..onPrimary = Colors.black
      ..onPrimaryVariant = Colors.white
      ..onSecondary = Colors.white
      ..onBackground = Colors.black
      //..onBackground = Colors.white.withOpacity(0.85)
      ..onSurface = Colors.red
      ..onError = Colors.white;

    // Black orange theme
    // ..primary = Colors.black
    // // ..primary = Color.fromRGBO(33, 150, 243, 1)
    // //..primary = Color.fromRGBO(53, 98, 17, 1)
    // ..primaryVariant = Colors.white
    // //..primaryVariant = Color.fromRGBO(0, 13, 22, 1)
    // // ..secondary = Color.fromRGBO(46, 189, 79, 1)
    // ..secondary = Color.fromRGBO(254, 176, 98, 1)
    // // ..secondary = Color.fromRGBO(242, 232, 128, 1)
    // ..secondaryVariant = Color.fromRGBO(13, 12, 29, 1)
    // ..accent1 = Color.fromRGBO(164, 96, 75, 1)
    // //..accent1 = Color.fromRGBObl(12, 12, 29, 1)
    // ..background = Colors.black
    // //..background = Color.fromRGBO(108, 143, 50, 1)
    // //..bg1 = Color.fromRGBO(82, 95, 103, 1)
    // ..surface = Colors.white
    // ..error = Colors.red.shade400
    // ..onPrimary = Colors.white
    // ..onPrimaryVariant = Colors.black
    // ..onSecondary = Colors.white
    // ..onBackground = Colors.white
    // //..onBackground = Colors.white.withOpacity(0.85)
    // ..onSurface = Colors.red
    // ..onError = Colors.white;

    return StoreProvider<AppState>(
      store: store,
      child: Provider.value(
        value: appTheme,
        child: MaterialApp(
          initialRoute: initialRoute,
          routes: {
            '/': (BuildContext context) => Home(),
            '/login': (BuildContext context) => Login(),
            '/verify-phone': (BuildContext context) => VerifyPhone(),
            '/enter-phone-number': (BuildContext context) => EnterPhoneNumber(),
            '/enter-sms-code': (BuildContext context) => EnterSMSCode(),
            '/signup': (BuildContext context) => SignUp(),
            '/signup-from-identity-provider': (BuildContext context) =>
                SignUpFromIdentityProvider(),
            '/dashboard': (BuildContext context) => Dashboard(),
            '/auto-start': (BuildContext context) => AutoStart(),
            '/create-a-nickname': (BuildContext context) => CreateANickname(),
            '/account': (BuildContext context) => Account(),
            '/password-reset': (BuildContext context) => PasswordReset(),
            '/animated-screen': (BuildContext context) => AnimatedScreen(),
          },
          theme: ThemeData(
            textTheme: GoogleFonts.notoSansTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          navigatorObservers: [routeObserver],
        ),
      ),
    );
  }
}
