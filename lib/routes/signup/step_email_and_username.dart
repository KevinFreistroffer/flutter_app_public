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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(Constants.APP_BAR_HEIGHT),
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              blurRadius: 5.0,
              spreadRadius: 5.0,
            ),
          ]),
          child: AppBar(
            iconTheme: IconThemeData(
              color: theme.onBackground.withOpacity(0.25),
            ),
            title: Text(
              'Step 1',
              style: TextStyle(
                color: theme.onBackground,
              ),
            ),
            centerTitle: true,
            backgroundColor: theme.primary,
          ),
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height - (Constants.APP_BAR_HEIGHT).roundToDouble(),
        color: theme.background,
        padding: EdgeInsets.fromLTRB(
          size.width * .1,
          size.width * .125,
          size.width * .1,
          size.width * .125,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  "Email",
                  style: TextStyle(
                    fontSize: 25,
                    color: theme.onBackground,
                  ),
                ),
              ],
            ),
            SizedBox(height: 7.5),
            new Theme(
              data: theme.themeData,
              child: TextFormField(
                style: TextStyle(
                  color: theme.onBackground,
                ),
                autofocus: true,
                cursorColor: theme.onBackground,
                decoration: InputDecoration(
                  hintText: 'example@example.com',
                  errorText: email.error,
                ),
                controller: emailTextController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (String value) {
                  handleOnChanged('email', value);
                },
              ),
            ),
            SizedBox(height: 25),
            Row(
              children: <Widget>[
                Text(
                  "Username",
                  style: TextStyle(
                    fontSize: 25,
                    color: theme.onBackground,
                  ),
                ),
              ],
            ),
            SizedBox(height: 9.5),
            new Theme(
              data: theme.themeData,
              child: TextFormField(
                style: TextStyle(
                  color: theme.onBackground,
                ),
                controller: usernameTextController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: 'Create a username',
                  errorText: username.error,
                ),
                onChanged: (String value) {
                  handleOnChanged('username', value);
                },
              ),
            ),
            SizedBox(height: 37),
            SubmitButton(
              text: 'Next',
              formIsValid: emailAndUsername.isValid(),
              isSubmitting: submitting,
              handleOnSubmit: () => handleOnSubmit(EmailAndUsername()),
            ),
          ],
        ),
      ),
    );
  }
}
