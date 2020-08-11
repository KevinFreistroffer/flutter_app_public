import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import '../../widgets/submit_button.dart';
import '../../widgets/AppBars/not_signed_in_app_bar.dart';
import 'styles.dart';
import '../../theme.dart';
import '../../constants.dart';
import './signup.dart';
import '../../widgets/welcome.text.dart';

class EmailAndUsernameStep extends StatelessWidget {
  final TextEditingController usernameTextController;
  final TextEditingController emailTextController;
  final PageController pageController;
  final EmailAndUsername emailAndUsername;
  final Email email;
  final Username username;
  final Map errors;
  final bool submitting;
  final InputChangeValue handleOnChanged;
  final FormSubmission handleOnSubmit;
  const EmailAndUsernameStep({
    Key key,
    this.usernameTextController,
    this.emailTextController,
    this.pageController,
    this.emailAndUsername,
    this.email,
    this.username,
    this.errors,
    this.submitting,
    this.handleOnChanged,
    this.handleOnSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppTheme theme = Provider.of<AppTheme>(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        image: DecorationImage(
          image: AssetImage('assets/black_and_white_mountains.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(Constants.APP_BAR_HEIGHT),
          child: Container(
            width: size.width,
            height: Constants.APP_BAR_HEIGHT + Constants.STATUS_BAR_HEIGHT,
            padding: EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: Colors.transparent,

              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.05),
              //     blurRadius: 5.0,
              //     spreadRadius: 5.0,
              //   ),
              // ],
            ),
            child: Stack(
              // crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: size.width,
                  margin: EdgeInsets.only(top: Constants.STATUS_BAR_HEIGHT),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: Constants.STATUS_BAR_HEIGHT),
                  child: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: theme.primary.withOpacity(
                              0.75,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: OrientationBuilder(
          builder: (context, orientation) {
            return Container(
              height: size.height,
              width: size.width,
              padding: EdgeInsets.fromLTRB(
                size.width * .1,
                0,
                size.width * .1,
                0,
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/solar_panels.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: Constants.STATUS_BAR_HEIGHT +
                            Constants.APP_BAR_HEIGHT,
                      ),
                      WelcomeText(leadingText: 'Sign Up For'),
                      SizedBox(height: 48),
                      Row(
                        children: <Widget>[
                          Text(
                            "Email",
                            style: TextStyle(
                              fontSize: 22,
                              color: theme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        style: TextStyle(
                          color: theme.primary,
                        ),
                        autofocus: false,
                        cursorColor: theme.primary,
                        decoration: InputDecoration(
                          hintText: 'example@example.com',
                          hintStyle: TextStyle(
                            color: theme.primary.withOpacity(0.5),
                          ),
                          errorText: email.error,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.primary.withOpacity(0.75),
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.primary.withOpacity(0.95),
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        controller: emailTextController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (String value) {
                          handleOnChanged('email', value);
                        },
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          Text(
                            "Username",
                            style: TextStyle(
                              fontSize: 22,
                              color: theme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        controller: usernameTextController,
                        cursorColor: theme.primary,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          hintText: 'Create a username',
                          hintStyle: TextStyle(
                            color: theme.primary.withOpacity(0.5),
                          ),
                          errorText: username.error,
                          errorStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.primary,
                              width: 1.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.primary.withOpacity(0.75),
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.primary.withOpacity(0.95),
                              width: 1.75,
                              style: BorderStyle.solid,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.red,
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                        ),
                        onChanged: (String value) {
                          handleOnChanged('username', value);
                        },
                      ),
                      SizedBox(height: 32),
                      SubmitButton(
                        text: 'NEXT',
                        formIsValid: emailAndUsername.isValid(),
                        isSubmitting: submitting,
                        handleOnSubmit: () => handleOnSubmit(
                          EmailAndUsername(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
