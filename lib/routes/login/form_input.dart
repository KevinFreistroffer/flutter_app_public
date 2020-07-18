import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import './styles.dart';
import '../../theme.dart';

typedef ValueChanged<T> = void Function(String type, String value);

class FormInput extends StatefulWidget {
  final String value;
  final String type;
  final String labelText;
  final String placeholder;
  final String label;
  final String hintText;
  final ValueChanged handleOnChange;
  final bool autofocus;
  final error;

  FormInput({
    Key key,
    @required this.value,
    @required this.type,
    @required this.labelText,
    @required this.placeholder,
    @required this.handleOnChange,
    @required this.error,
    this.hintText,
    this.label,
    this.autofocus = false,
  }) : super(key: key);
  @override
  _FormInputState createState() => _FormInputState();
}

class _FormInputState extends State<FormInput> {
  bool _obscureText;

  @override
  initState() {
    _obscureText = widget.type == 'password' ? true : false;
  }

  _toggleObscureText() {
    setState(() => _obscureText = !_obscureText);
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Provider.of<AppTheme>(context);
    //dynamic? error;
    dynamic _error;

    if (widget.type == 'usernameOrEmail') {
      if (widget.error != Constants.ERROR_USERNAME_REQUIRED) {
        _error = null;
      } else {
        _error = widget.error;
      }
    } else if (widget.type == 'password') {
      if (widget.error != Constants.ERROR_PASSWORD_REQUIRED) {
        _error = null;
      } else {
        _error = widget.error;
      }
    }

    return Container(
      // padding: EdgeInsets.only(top: 5, right: 10, bottom: 5, left: 20),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.labelText,
                  style: TextStyle(
                    fontSize: 25,
                    color: theme.onBackground,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 8),
          TextFormField(
            textCapitalization: TextCapitalization.none,
            // focusNode: _focusNode,

            autofocus: widget.autofocus,
            style: TextStyle(
              color: Colors.white,
            ),

            //inputFormatters: [OrderInputFormatter()],
            decoration: InputDecoration(
              hintText: widget.hintText,
              errorText: widget.error,
              suffixIcon: widget.type == 'password'
                  ? IconButton(
                      icon: _obscureText
                          ? Icon(Icons.visibility,
                              color: theme.onBackground.withOpacity(0.5))
                          : Icon(
                              Icons.visibility_off,
                              color: theme.onBackground.withOpacity(0.5),
                            ),
                      onPressed: () {
                        _toggleObscureText();
                      })
                  : null,
            ),
            keyboardType: widget.type == 'emailOrUsername'
                ? TextInputType.emailAddress
                : null,
            onChanged: (value) {
              widget.handleOnChange(widget.type, value);
            },

            obscureText: _obscureText,
          ),
        ],
      ),
    );
  }
}
