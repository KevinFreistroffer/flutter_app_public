import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/submit_button.dart';
import 'styles.dart';
import '../../theme.dart';
import '../../constants.dart';
import './signup.dart';

class PasswordsStep extends StatefulWidget {
  final PageController pageController;
  final Password password;
  final ConfirmPassword confirmPassword;
  final bool submitting;
  final Function handleOnChanged;
  final FormSubmission handleOnSubmit;

  PasswordsStep({
    Key key,
    this.pageController,
    this.password,
    this.confirmPassword,
    this.submitting,
    this.handleOnSubmit,
    this.handleOnChanged,
  }) : super(key: key);

  @override
  _PasswordsStepState createState() => _PasswordsStepState();
}

class _PasswordsStepState extends State<PasswordsStep> {
  bool _obscurePasswordText = true;
  bool _obscureConfirmText = true;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppTheme theme = Provider.of<AppTheme>(context);

    final Icon passwordIcon = _obscurePasswordText
        ? Icon(
            Icons.visibility,
            color: theme.onBackground.withOpacity(0.5),
          )
        : Icon(
            Icons.visibility_off,
            color: theme.onBackground.withOpacity(0.5),
          );
    final Icon confirmPasswordIcon = _obscureConfirmText
        ? Icon(
            Icons.visibility,
            color: theme.onBackground.withOpacity(0.5),
          )
        : Icon(
            Icons.visibility_off,
            color: theme.onBackground.withOpacity(0.5),
          );

    return Scaffold(
      key: PageStorageKey(1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: theme.onBackground.withOpacity(0.25),
        ),
        title: Text(
          'Step 2',
          style: TextStyle(color: theme.onBackground),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _obscurePasswordText = false;
              _obscureConfirmText = false;
            });
            widget.pageController.jumpToPage(0);
          },
        ),
        backgroundColor: theme.primary,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: size.height - (Constants.APP_BAR_HEIGHT * 2).roundToDouble(),
          padding: EdgeInsets.fromLTRB(size.width * .1, 0, size.width * .1, 0),
          color: theme.background,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Create a password",
                style: TextStyle(fontSize: 25, color: theme.onBackground),
              ),
              SizedBox(height: 7.5),
              new Theme(
                data: theme.themeData,
                child: TextFormField(
                  style: TextStyle(
                    color: theme.onBackground,
                  ),
                  cursorColor: theme.onBackground,
                  decoration: InputDecoration(
                    hintText: 'At least 6 characters',
                    labelText: null,
                    errorText: widget.password.error,
                    suffixIcon: IconButton(
                      icon: passwordIcon,
                      onPressed: () {
                        setState(
                          () => _obscurePasswordText = !_obscurePasswordText,
                        );
                      },
                    ),
                  ),
                  obscureText: _obscurePasswordText,
                  onChanged: (String value) {
                    widget.handleOnChanged('password', value);
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Enter password again",
                style: TextStyle(
                  fontSize: 25,
                  color: theme.onBackground,
                ),
              ),
              SizedBox(height: 7.5),
              new Theme(
                data: theme.themeData,
                child: TextFormField(
                  style: TextStyle(
                    color: theme.onBackground,
                  ),
                  cursorColor: theme.onBackground,
                  decoration: InputDecoration(
                    labelText: '',
                    errorText: widget.confirmPassword.error,
                    suffixIcon: IconButton(
                      icon: confirmPasswordIcon,
                      onPressed: () {
                        setState(
                            () => _obscureConfirmText = !_obscureConfirmText);
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmText,
                  onChanged: (String value) {
                    widget.handleOnChanged('confirmPassword', value);
                  },
                ),
              ),
              SizedBox(height: 37),
              SubmitButton(
                text: 'Next',
                formIsValid: widget.password.isValid() &&
                    widget.confirmPassword.isValid(),
                isSubmitting: widget.submitting,
                handleOnSubmit: () => widget.handleOnSubmit(Passwords()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
