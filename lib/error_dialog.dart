import 'package:flutter/material.dart';

class ErrorDialogStyles {
  static const Map alertDialog = {
    //'titlePadding': EdgeInsets.fromLTRB(24, 24, 24, 0),
    'titlePadding': EdgeInsets.all(0),
    'buttonPadding': EdgeInsets.fromLTRB(24, 0, 24, 0),
    'contentPadding': EdgeInsets.all(30),
    'actions': {
      'flatButton': {
        'text': {
          'fontSize': 16.0,
          'fontWeight': FontWeight.w900,
        }
      }
    },
  };
}

class ErrorDialog {
  static displayErrorDialog(
    BuildContext context,
    String error, {
    bool barrierDismissible = true,
  }) {
    final styles = ErrorDialogStyles.alertDialog;
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible, // user must tap button!
      builder: (BuildContext context) {
        final Size size = MediaQuery.of(context).size;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: Colors.red[300],
            ),
            padding: EdgeInsets.fromLTRB(
              size.width * .1,
              size.width * .125,
              size.width * .1,
              size.width * .125,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.error,
                  size: 70,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          titlePadding: styles['titlePadding'],
          buttonPadding: styles['buttonPadding'],
          contentPadding: styles['contentPadding'],
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.4,
                    fontWeight: FontWeight.w100,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            GestureDetector(
              child: Text(
                'DISMISS',
                style: TextStyle(
                  fontSize: styles['actions']['flatButton']['text']['fontSize'],
                  fontWeight: styles['actions']['flatButton']['text']
                      ['fontWeight'],
                  color: Colors.black45,
                ),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
