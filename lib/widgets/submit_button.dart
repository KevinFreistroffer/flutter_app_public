import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../constants.dart';

class SubmitButton extends StatefulWidget {
  final String text;
  final Function handleOnSubmit;
  final bool isSubmitting;
  final bool formIsValid;

  const SubmitButton({
    Key key,
    @required this.text,
    @required this.handleOnSubmit,
    @required this.isSubmitting,
    @required this.formIsValid,
    // @required this.formIsValid,
  }) : super(key: key);

  @override
  _SubmitButtonState createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  @override
  void didUpdateWidget(SubmitButton oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final AppTheme theme = Provider.of<AppTheme>(context);
    dynamic child;

    if (!widget.isSubmitting) {
      child = Text(
        widget.text ?? 'NEXT',
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Colors.black.withOpacity(0.75),
        ),
      );
    } else {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Loading(
            indicator: BallPulseIndicator(),
            size: 20.0,
            color: Colors.black.withOpacity(0.75),
          ),
        ],
      );
    }

    RoundedRectangleBorder shape;

    if (!widget.isSubmitting) {
      shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      );
    } else {
      shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(
          color: theme.onBackground.withOpacity(0.25),
          width: 1.0,
        ),
      );
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: Theme(
            data: theme.themeData,
            child: RaisedButton(
              shape: shape,
              padding: EdgeInsets.fromLTRB(10, 17, 10, 17),
              disabledColor: Colors.yellow,
              disabledTextColor: theme.onBackground,
              onPressed: widget.isSubmitting ? null : widget.handleOnSubmit,
              child: child,
              textColor: Colors.white,
            ),
          ),
        )
      ],
    );
  }
}
