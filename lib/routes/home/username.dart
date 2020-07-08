import 'package:flutter/material.dart';
import '../../services/authentication.service.dart';
import './styles.dart';

class AddAUsername extends StatefulWidget {
  final TextEditingController controller;
  final Function onChange;
  final Function onSubmit;
  final Function goBack;
  final bool submitDisabled;
  final String username;
  final String error;
  AddAUsername({
    Key key,
    this.controller,
    this.onChange,
    this.onSubmit,
    this.goBack,
    this.submitDisabled,
    this.username,
    this.error,
  }) : super(key: key);

  @override
  _AddAUsernameState createState() => _AddAUsernameState();
}

class _AddAUsernameState extends State<AddAUsername> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final styles = Styles.formInput;

    return Container(
      padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Add a username',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Form(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      // padding: EdgeInsets.only(top: 5, right: 10, bottom: 5, left: 20),
                      margin: styles['container']['margin'],
                      decoration: BoxDecoration(),
                      child: TextFormField(
                        controller: widget.controller,
                        style: Styles.formInput['color'],
                        decoration: InputDecoration(
                          contentPadding: styles['decoration']
                              ['contentPadding'],
                          filled: true,
                          fillColor: styles['decoration']['fillColor'],
                          hintText: 'Enter a username',
                          labelText: 'Username',
                          labelStyle: styles['decoration']['labelStyle'],
                          focusedBorder: InputBorder.none,
                          errorText: widget.error,
                          errorStyle: styles['decoration']['errorStyle'],
                          prefixIcon: null,
                          errorMaxLines: 2,
                          counterText: '',
                        ),
                        autofocus: false,
                        onChanged: widget.onChange,
                        obscureText: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: size.width,
              child: RaisedButton(
                child: Text('Next'),
                onPressed: () {
                  if (widget.submitDisabled) {
                    return null;
                  } else {
                    widget.onSubmit();
                  }
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Go back',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              onTap: widget.goBack,
            ),
          ],
        ),
      ),
    );
  }
}
