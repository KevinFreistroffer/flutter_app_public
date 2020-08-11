import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_keto/constants.dart';
import 'package:flutter_keto/theme.dart';

class WelcomeText extends StatelessWidget {
  String leadingText;
  WelcomeText({Key key, this.leadingText = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = Provider.of<AppTheme>(context);
    final Size size = MediaQuery.of(context).size;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.yellow,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${leadingText.toUpperCase()}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0,
                          color: theme.primary,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Pi Solar',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Tracker',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.luckiestGuy(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0,
                          color: theme.primary,
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
