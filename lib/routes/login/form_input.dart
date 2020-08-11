import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    super.initState();
  }

  void _toggleObscureText() {
    setState(() => _obscureText = !_obscureText);
  }

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Provider.of<AppTheme>(context);

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                widget.labelText,
                style: TextStyle(
                  fontSize: 22,
                  color: theme.primary,
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 8),
        // new Theme(
        //                       data: theme.themeData,
        //                       child: TextFormField(
        //                         style: TextStyle(
        //                           color: theme.onBackground,
        //                         ),
        //                         cursorColor: Colors.black,
        //                         decoration: InputDecoration(
        //                           hintText: 'example@example.com',
        //                           errorText: _errors['email'],
        //                           focusedBorder: OutlineInputBorder(
        //                             borderSide: BorderSide(
        //                               color: Colors.black.withOpacity(0.5),
        //                               width: 2.0,
        //                             ),
        //                           ),
        //                         ),
        //                         keyboardType: TextInputType.emailAddress,
        //                         onChanged: (value) =>
        //                             _handlesFormInputsChangeValue(value),
        //                       ),
        //                     ),
        new Theme(
          data: theme.themeData,
          child: TextFormField(
            textCapitalization: TextCapitalization.none,
            // focusNode: _focusNode,
            autofocus: widget.autofocus,
            style: TextStyle(color: theme.onBackground),
            //inputFormatters: [OrderInputFormatter()],
            cursorColor: theme.primary,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: theme.primary.withOpacity(0.5),
              ),
              errorText: widget.error,
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
              suffixIcon: widget.type == 'password'
                  ? IconButton(
                      icon: _obscureText
                          ? Icon(Icons.visibility,
                              color: theme.primary.withOpacity(0.5))
                          : Icon(
                              Icons.visibility_off,
                              color: theme.primary.withOpacity(0.5),
                            ),
                      onPressed: () => _toggleObscureText())
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
        ),
      ],
    );
  }
}
